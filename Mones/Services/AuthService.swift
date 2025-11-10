//
//  AuthSrvice.swift
//  Mones
//
//  Created by Zakhar on 05.11.25.
//

import Foundation
import LocalAuthentication
import Combine
import SwiftUI

enum LockError: String, Error {
    case faceIDNotAvailable = "Face ID is not available on this device"
    case authFallback       = "Authentication failed"
    case invalidPin         = "Invalid PIN"
}

@MainActor
final class LockManager: ObservableObject {
    enum State { case locked, unlocking, unlocked }
    enum Mode { case verify, setup }

    // MARK: - Public state
    @Published var successMessage: String?
    @Published private(set) var state: State = .locked
    @Published private(set) var mode: Mode = .verify
    @Published private(set) var userCodeInput: String = ""
    @Published var error: LockError?
    
    
    @Published var isBiometryAllowed: Bool = UserDefaults.standard.bool(forKey: "isBiometryAllowed") {
        didSet {
            UserDefaults.standard.set(isBiometryAllowed, forKey: "isBiometryAllowed")
        }
    }
    
    // MARK: - Config
    private let pinLength = 4
    private let keychainAccount = "app.passcode.record"
    private var isAuthenticating = false

    // MARK: - Combine
    private var bag = Set<AnyCancellable>()

    // MARK: - Init
    init() {
        mode = (try? Keychain.read(account: keychainAccount)) == nil ? .setup : .verify

        setupPipelines()
    }

    // MARK: - Public API
    func setSymbol(_ str: String) {
        guard userCodeInput.count < pinLength, str.allSatisfy(\.isNumber) else { return }
        userCodeInput.append(str)
    }
    
    func removeLast() {
        userCodeInput = String(userCodeInput.dropLast())
    }

    func lock() { state = .locked }

    func didUnlock() {
        pendingAction?()
        pendingAction = nil
    }

    func performSecured(_ action: @escaping () -> Void) {
        if state == .unlocked { action() }
        else {
            pendingAction = action
            state = .locked
        }
    }

    // MARK: - Face ID (через Combine Future)
    func authenticateWithFaceID() {
        guard !isAuthenticating else { return }
        
        let context = LAContext()
        var err: NSError?
        
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &err) else {
            self.error = .faceIDNotAvailable
            return
        }
        
        isAuthenticating = true
        state = .unlocking
        
        Future<Bool, Never> { promise in
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics,
                                   localizedReason: "Unlock the app") { success, _ in
                promise(.success(success))
            }
        }
        .receive(on: DispatchQueue.main)
        .sink { [weak self] success in
            guard let self = self else { return }
            self.isAuthenticating = false // Сбрасываем флаг
            // ... остальная логика
        }
        .store(in: &bag)
    }
    
    func resetPasscode() {
        Keychain.delete(account: keychainAccount)
        mode = .setup
        state = .locked
        userCodeInput = ""
        error = nil
        pendingAction = nil
        isBiometryAllowed = false
        successMessage = "Passcode has been reset successfully"
        
        // Автоматически скрываем сообщение через 3 секунды
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            self?.successMessage = nil
        }
    }


    // MARK: - Private
    private var pendingAction: (() -> Void)?

    private func setupPipelines() {
        $userCodeInput
            .filter { [weak self] in $0.count == self?.pinLength }
            .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
            .flatMap { [weak self] code -> AnyPublisher<Bool, Never> in
                guard let self = self else { return Just(false).eraseToAnyPublisher() }
                switch self.mode {
                case .verify:
                    return self.verifyPINPublisher(code)
                case .setup:
                    return self.setupPINPublisher(code)
                }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] ok in
                guard let self else { return }
                if ok {
                    self.state = .unlocked
                    self.error = nil
                    self.userCodeInput = ""
                    self.didUnlock()
                } else {
                    self.state = .locked
                    self.error = .invalidPin
                    self.userCodeInput = ""
                }
            }
            .store(in: &bag)

        Publishers.CombineLatest($isBiometryAllowed.removeDuplicates(),
                                 $state.removeDuplicates())
            .filter { allowed, st in allowed && st == .locked }
            .sink { [weak self] _ in
                self?.authenticateWithFaceID()
            }
            .store(in: &bag)
    }

    private func verifyPINPublisher(_ code: String) -> AnyPublisher<Bool, Never> {
        Future<Bool, Never> { [weak self] promise in
            guard let self = self else { return promise(.success(false)) }
            do {
                let data = try Keychain.read(account: self.keychainAccount)
                let rec = try JSONDecoder().decode(PasscodeRecord.self, from: data)
                let computed = hashPIN(code, salt: rec.salt)
                print()
                promise(.success(computed == rec.hash))
            } catch KeychainError.notFound {
                // Специальная обработка для случая, когда PIN не настроен
                print("PIN not set up")
                promise(.success(false))
            } catch {
                print("Keychain error: \(error)")
                promise(.success(false))
            }
        }
        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
        .eraseToAnyPublisher()
    }

    private func setupPINPublisher(_ code: String) -> AnyPublisher<Bool, Never> {
        Future<Bool, Never> { [weak self] promise in
            guard let self = self else { return promise(.success(false)) }
            let salt = randomSalt()
            let h = hashPIN(code, salt: salt)
            let rec = PasscodeRecord(salt: salt, hash: h)
            do {
                let data = try JSONEncoder().encode(rec)
                try Keychain.save(data: data, account: self.keychainAccount)
                promise(.success(true))
            } catch {
                promise(.success(false))
            }
        }
        .handleEvents(receiveOutput: { [weak self] ok in
            if ok { self?.mode = .verify }
        })
        .subscribe(on: DispatchQueue.global(qos: .userInitiated))
        .eraseToAnyPublisher()
    }
}
