//
//  BankAccountModel.swift
//  Mones
//
//  Created by Zakhar on 04.11.25.
//

import Foundation

enum PeymentSystem: String, Codable {
    case visa = "Visa"
    case masterCard = "Master Card"
}

enum AccountType: String, Codable {
    case creditCard = "Credit Card"
    case debitCard = "Debit Card"
    case savingsAccount = "Savings Account"
    case investmentAccount = "Investment Account"
    
    var iconName: String {
        switch self {
        case .creditCard: return "creditcard"
        case .debitCard: return "creditcard.fill"
        case .savingsAccount: return "banknote"
        case .investmentAccount: return "chart.line.uptrend.xyaxis"
        }
    }
}

enum CardStatus: String, Codable {
    case active = "Active"
    case blocked = "Blocked"
    case expired = "Expired"
    case pending = "Pending"
}
