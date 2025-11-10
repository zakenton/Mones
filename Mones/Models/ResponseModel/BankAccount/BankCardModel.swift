//
//  File.swift
//  Mones
//
//  Created by Zakhar on 04.11.25.
//

import Foundation

struct BankCard: Identifiable, Codable {
    let id: UUID
    let balance: Double
    let cardNumber: String
    let cardHolderName: String
    let expirationDate: Date
    let cvv: String
    let paymantSystem: PeymentSystem
    let cardType: AccountType
    let status: CardStatus
    let spendingLimit: Double?
    let availableCredit: Double?
    
    // MARK: Init
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
    
    // MARK: - Helpers
    var formattedCardNumber: String {
        let cleanedNumber = cardNumber.replacingOccurrences(of: " ", with: "")
        return addSpaces(to: cleanedNumber)
    }
    
    var maskedCardNumber: String {
        let cleaned = cardNumber.replacingOccurrences(of: " ", with: "")
        let hiddenPart = String(repeating: "•", count: cleaned.count - 4)
        return addSpaces(to: hiddenPart)
    }
    
    var formattedExpirarionData: String {
        let formater = DateFormatter()
        formater.dateFormat = "MM/yy"
        return formater.string(from: expirationDate)
    }
}


//MARK: - Privaet Methods
extension BankCard {
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
