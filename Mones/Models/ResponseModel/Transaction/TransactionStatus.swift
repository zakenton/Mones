//
//  TransactionStatus.swift
//  Mones
//
//  Created by Zakhar on 03.11.25.
//

import Foundation

enum TransactionStatus: Codable, Equatable {
    case pending                      // В обработке
    case delayed(until: Date)        // Отправлена с задержкой
    case completed                   // Выполнена
    case received                    // Получена
    case failed(reason: String)      // Неуспешна (с причиной)
    case cancelled                   // Отменена
    case refunded(amount: Double)    // Возвращена (с суммой возврата)
    
    // Вычисляемое свойство для отображения в UI
    var displayName: String {
        switch self {
        case .pending:
            return "В обработке"
        case .delayed:
            return "Задержка"
        case .completed:
            return "Выполнена"
        case .received:
            return "Получена"
        case .failed:
            return "Ошибка"
        case .cancelled:
            return "Отменена"
        case .refunded:
            return "Возвращена"
        }
    }
    
    // Цвет для отображения статуса
    var color: String {
        switch self {
        case .pending: return "orange"
        case .delayed: return "yellow"
        case .completed: return "green"
        case .received: return "blue"
        case .failed: return "red"
        case .cancelled: return "gray"
        case .refunded: return "purple"
        }
    }
    
    // Иконка для статуса
    var icon: String {
        switch self {
        case .pending: return "hourglass"
        case .delayed: return "clock.badge.exclamationmark"
        case .completed: return "checkmark.circle"
        case .received: return "checkmark.circle.fill"
        case .failed: return "xmark.circle"
        case .cancelled: return "xmark.circle.fill"
        case .refunded: return "arrow.uturn.left"
        }
    }
}
