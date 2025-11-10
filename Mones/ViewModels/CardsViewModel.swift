//
//  CardsViewModel.swift
//  Mones
//
//  Created by Zakhar on 04.11.25.
//

import Foundation
import Combine

class BankCardViewModel: ObservableObject, Identifiable {
    let id: UUID
    
    @Published var balance: Double
    @Published var cardNumber: String
    @Published var cardHolderName: String
    @Published var expirationDate: Date
    @Published var cvv: String
    @Published var paymantSystem: PeymentSystem
    @Published var cardType: AccountType
    @Published var status: CardStatus
    @Published var spendingLimit: Double?
    @Published var availableCredit: Double?
    
    
    var formattedCardNumber: String {
        let cleanedNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        return addSpaces(to: cleanedNumber)
    }
    
    var maskedCardNumber: String {
        let cleaned = cardNumber.replacingOccurrences(of: " ", with: "")
        let lastFour = String(cleaned.suffix(4))
        let hiddenPart = String(repeating: "•", count: cleaned.count - 4)
        return addSpaces(to: hiddenPart + lastFour)
    }
    
    var formattedExpirarionData: String {
        let formater = DateFormatter()
        formater.dateFormat = "MM/yy"
        return formater.string(from: expirationDate)
    }
    
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
        self.cardNumber = cardNumber
        self.cardHolderName = cardHolderName
        self.expirationDate = expirationDate
        self.cvv = cvv
        self.paymantSystem = paymantSystem
        self.cardType = cardType
        self.status = status
        self.spendingLimit = spendingLimit
        self.availableCredit = availableCredit
    }
    
    // Convenience init for Response Model
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
    
    // MARK: - Methods
    func updateBalance(_ newBalance: Double) {
        balance = newBalance
    }
    
    func updateStatus(_ newStatus: CardStatus) {
        status = newStatus
    }
    
    func updateSpendingLimit(_ newLimit: Double?) {
        spendingLimit = newLimit
    }
    
    private func addSpaces(to cleaned: String) -> String {
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

// MARK: - Mock Data Extension
extension BankCardViewModel {
    
    static var mock: BankCardViewModel {
        BankCardViewModel(
            balance: 2450.75,
            cardNumber: "4111111111111111",
            cardHolderName: "JOHN DOE",
            expirationDate: Date().addingTimeInterval(365 * 24 * 60 * 60 * 2), // +2 years
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

class CardsViewModel: ObservableObject {
    @Published var cards: [BankCardViewModel] = []
    @Published var selectedCard: BankCardViewModel?
    @Published var isLoading: Bool = false
}

extension CardsViewModel: Mockable {
    typealias MockObject = CardsViewModel
    
    static var mock: CardsViewModel {
        let viewModel = CardsViewModel()
        viewModel.cards = BankCardViewModel.mockArray
        viewModel.selectedCard = BankCardViewModel.mockArray.first
        return viewModel
    }
    
    static var mockArray: [CardsViewModel] {
        let viewModel1 = CardsViewModel()
        viewModel1.cards = Array(BankCardViewModel.mockArray.prefix(2))
        viewModel1.selectedCard = BankCardViewModel.mockArray.first
        
        let viewModel2 = CardsViewModel()
        viewModel2.cards = Array(BankCardViewModel.mockArray.suffix(2))
        viewModel2.selectedCard = BankCardViewModel.mockArray.last
        
        return [viewModel1, viewModel2]
    }
    
    // Мок с пустым списком карт
    static var mockEmpty: CardsViewModel {
        let viewModel = CardsViewModel()
        viewModel.cards = []
        viewModel.isLoading = false
        return viewModel
    }
    
    // Мок с загрузкой
    static var mockLoading: CardsViewModel {
        let viewModel = CardsViewModel()
        viewModel.isLoading = true
        return viewModel
    }
}

// MARK: - Mock Protocol
protocol Mockable: ObservableObject {
    associatedtype MockObject
    static var mock: MockObject { get }
    static var mockArray: [MockObject] { get }
}

