//
//  CardsViewModel.swift
//  Mones
//
//  Created by Zakhar on 04.11.25.
//

import Foundation
import Combine

/// Базовый интерфейс для отображения карты в UI
protocol BankCardDisplayable: ObservableObject, Identifiable {
    // Основные данные
    var balance: Double { get }
    var cardHolderName: String { get }
    var paymantSystem: PeymentSystem { get }
    var cardType: AccountType { get }
    var status: CardStatus { get }
    
    // Даты / формат
    var expirationDate: Date { get }
    var formattedExpirationDate: String { get }
    
    // Номер карты
    var formattedCardNumber: String { get }   // 1234 5678 9012 3456
    var maskedCardNumber: String { get }      // •••• •••• •••• 3456
    
    var cvv: String { get }        /// full
    var maskedCVV: String { get }  /// masked
}




final class BankCardViewModel: BankCardDisplayable {
    // MARK: - Identifiable
    let id: UUID
    
    // MARK: - Public (но с контролем записи)
    @Published private(set) var balance: Double
    @Published private(set) var cardHolderName: String
    @Published private(set) var expirationDate: Date
    @Published private(set) var paymantSystem: PeymentSystem
    @Published private(set) var cardType: AccountType
    @Published private(set) var status: CardStatus
    @Published private(set) var spendingLimit: Double?
    @Published private(set) var availableCredit: Double?
    
    // Чувствительные данные
    @Published private(set) var cardNumber: String   // храним очищенным
    @Published private(set) var cvv: String
    
    // MARK: - Init
    init(
        id: UUID = UUID(),
        balance: Double,
        cardNumber: String,
        cardHolderName: String,
        expirationDate: Date,
        cvv: String,
        paymantSystem: PeymentSystem,
        cardType: AccountType,
        status: CardStatus = .active,
        spendingLimit: Double? = nil,
        availableCredit: Double? = nil
    ) {
        self.id = id
        self.balance = balance
        self.cardHolderName = cardHolderName
        self.expirationDate = expirationDate
        self.cvv = cvv
        self.paymantSystem = paymantSystem
        self.cardType = cardType
        self.status = status
        self.spendingLimit = spendingLimit
        self.availableCredit = availableCredit
        self.cardNumber = cardNumber.replacingOccurrences(of: " ", with: "")
    }
    
    // Convenience init для response-модели
    convenience init(from card: BankCard) {
        self.init(
            id: card.id,
            balance: card.balance,
            cardNumber: card.cardNumber,
            cardHolderName: card.cardHolderName,
            expirationDate: card.expirationDate,
            cvv: card.cvv,
            paymantSystem: card.paymantSystem,
            cardType: card.cardType,
            status: card.status,
            spendingLimit: card.spendingLimit,
            availableCredit: card.availableCredit
        )
    }
    
    // MARK: - Mutating methods
    func updateBalance(_ newBalance: Double) {
        balance = newBalance
    }
    
    func updateStatus(_ newStatus: CardStatus) {
        status = newStatus
    }
    
    func updateSpendingLimit(_ newLimit: Double?) {
        spendingLimit = newLimit
    }
    
    func updateCardHolderName(_ newName: String) {
        cardHolderName = newName
    }
    
    func updateExpirationDate(_ newDate: Date) {
        expirationDate = newDate
    }
    
    func updateCVV(_ newCVV: String) {
        cvv = newCVV
    }
}

// MARK: - Formatting
private extension BankCardViewModel {
    static let expirationFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        return formatter
    }()
    
    var cleanedCardNumber: String {
        cardNumber // уже без пробелов, мы чистим в init
    }
    
    func addSpaces(to cleaned: String) -> String {
        var result = ""
        for (index, character) in cleaned.enumerated() {
            if index > 0 && index % 4 == 0 {
                result += " "
            }
            result.append(character)
        }
        return result
    }
}

// MARK: - BankCardDisplayable
extension BankCardViewModel {
    
    var formattedCardNumber: String {
        addSpaces(to: cleanedCardNumber)
    }
    
    var maskedCardNumber: String {
        let cleaned = cleanedCardNumber
        let lastFour = String(cleaned.suffix(4))
        let hiddenPart = String(repeating: "•", count: max(cleaned.count - 4, 0))
        return addSpaces(to: hiddenPart + lastFour)
    }
    
    var formattedExpirationDate: String {
        Self.expirationFormatter.string(from: expirationDate)
    }
    
    var maskedCVV: String {
        String(repeating: "•", count: cvv.count)
    }
}


// MARK: - Mock Data Extension
extension BankCardViewModel {
    
    static var mock: BankCardViewModel {
        BankCardViewModel(
            balance: 2450.75,
            cardNumber: "4111111111111111",
            cardHolderName: "JOHN DOE",
            expirationDate: Date().addingTimeInterval(365 * 24 * 60 * 60 * 2),
            cvv: "123",
            paymantSystem: .visa,
            cardType: .debitCard,
            status: .active,
            spendingLimit: nil,
            availableCredit: nil
        )
    }
    
    static var mockArray: [BankCardViewModel] {
        [
            BankCardViewModel(
                balance: 2450.75,
                cardNumber: "4111111111111111",
                cardHolderName: "JOHN DOE",
                expirationDate: Date().addingTimeInterval(365 * 24 * 60 * 60 * 2),
                cvv: "123",
                paymantSystem: .visa,
                cardType: .debitCard,
                status: .active
            ),
            BankCardViewModel(
                balance: -1250.50,
                cardNumber: "5555555555554444",
                cardHolderName: "JOHN DOE",
                expirationDate: Date().addingTimeInterval(365 * 24 * 60 * 60 * 3),
                cvv: "456",
                paymantSystem: .masterCard,
                cardType: .creditCard,
                status: .active,
                spendingLimit: 10000.0,
                availableCredit: 8749.50
            ),
            BankCardViewModel(
                balance: 15000.00,
                cardNumber: "378282246310005",
                cardHolderName: "JOHN DOE",
                expirationDate: Date().addingTimeInterval(365 * 24 * 60 * 60),
                cvv: "789",
                paymantSystem: .visa,
                cardType: .savingsAccount,
                status: .active
            ),
            BankCardViewModel(
                balance: 50000.25,
                cardNumber: "6011111111111117",
                cardHolderName: "JOHN DOE",
                expirationDate: Date().addingTimeInterval(365 * 24 * 60 * 60 * 4),
                cvv: "321",
                paymantSystem: .masterCard,
                cardType: .investmentAccount,
                status: .active
            )
        ]
    }
    
    // Дополнительные мок данные для разных статусов
    static var mockBlockedCard: BankCardViewModel {
        BankCardViewModel(
            balance: 0.0,
            cardNumber: "4222222222222222",
            cardHolderName: "JOHN DOE",
            expirationDate: Date().addingTimeInterval(365 * 24 * 60 * 60),
            cvv: "999",
            paymantSystem: .visa,
            cardType: .debitCard,
            status: .blocked
        )
    }
    
    static var mockExpiredCard: BankCardViewModel {
        BankCardViewModel(
            balance: 100.0,
            cardNumber: "4333333333333333",
            cardHolderName: "JOHN DOE",
            expirationDate: Date().addingTimeInterval(-365 * 24 * 60 * 60), // -1 year (expired)
            cvv: "888",
            paymantSystem: .masterCard,
            cardType: .creditCard,
            status: .expired,
            spendingLimit: 5000.0,
            availableCredit: 4900.0
        )
    }
}

