//
//  TransactionCategory.swift
//  Mones
//
//  Created by Zakhar on 03.11.25.
//

import Foundation
enum TransactionCategory: String, Codable, CaseIterable {
    case food        // Еда
    case transport   // Транспорт
    case shopping    // Шопинг
    case bills       // Счета
    case entertainment // Развлечения
    case healthcare  // Здоровье
    case salary      // Зарплата
    case transfer    // Перевод
    case other       // Другое
    
    var displayName: String {
        switch self {
        case .food: return "Food"
        case .transport: return "Transport"
        case .shopping: return "Shopping"
        case .bills: return "Bills"
        case .entertainment: return "Entertainment"
        case .healthcare: return "Healthcare"
        case .salary: return "Salary"
        case .transfer: return "Transfer"
        case .other: return "Other"
        }
    }
    
    var icon: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car"
        case .shopping: return "bag"
        case .bills: return "doc.text"
        case .entertainment: return "film"
        case .healthcare: return "heart"
        case .salary: return "dollarsign.circle"
        case .transfer: return "arrow.left.arrow.right"
        case .other: return "questionmark.circle"
        }
    }
}
