//
//  TransactionType.swift
//  Mones
//
//  Created by Zakhar on 03.11.25.
//

import Foundation
enum TransactionType: String, Codable, CaseIterable {
    case transfer    // Перевод
    case payment     // Платеж
    case deposit     // Пополнение
    case withdrawal  // Снятие
    case refund      // Возврат
    case fee         // Комиссия
    
    var displayName: String {
        switch self {
        case .transfer: return "Перевод"
        case .payment: return "Платеж"
        case .deposit: return "Пополнение"
        case .withdrawal: return "Снятие"
        case .refund: return "Возврат"
        case .fee: return "Комиссия"
        }
    }
}
