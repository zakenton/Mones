//
//  TransactionModel.swift
//  Mones
//
//  Created by Zakhar on 03.11.25.
//

import Foundation
import SwiftUI

// MARK: - Основная модель транзакции
struct Transaction: Identifiable, Codable {
    let id: UUID
    let name: String
    let status: TransactionStatus
    let image: URL?
    let description: String
    let amount: Double
    let currency: String
    let type: TransactionType
    let category: TransactionCategory
    let date: Date
    let sender: String?
    let recipient: String?
    let reference: String?
    
    init(
        id: UUID = UUID(),
        name: String,
        status: TransactionStatus,
        image: URL? = nil,
        description: String,
        amount: Double,
        currency: String = "USD",
        type: TransactionType,
        category: TransactionCategory,
        date: Date = Date(),
        sender: String? = nil,
        recipient: String? = nil,
        reference: String? = nil
    ) {
        self.id = id
        self.name = name
        self.status = status
        self.image = image
        self.description = description
        self.amount = amount
        self.currency = currency
        self.type = type
        self.category = category
        self.date = date
        self.sender = sender
        self.recipient = recipient
        self.reference = reference
    }
    
    // Вычисляемое свойство для знака суммы
    var amountWithSign: String {
        let sign = type == .deposit || type == .refund ? "+" : "-"
        return "\(sign)\(amount) \(currency)"
    }
    
    // Вычисляемое свойство для цвета суммы
    var amountColor: Color {
        switch type {
        case .deposit, .refund:
            return .green
        case .withdrawal, .payment, .fee:
            return .red
        case .transfer:
            return .blue
        }
    }
}

// MARK: - Ответ от сервера
struct TransactionsResponse: Codable {
    let transactions: [Transaction]
    let totalCount: Int
    let page: Int
    let totalPages: Int
    let hasMore: Bool
}

// MARK: - Фильтр для транзакций
struct TransactionFilter: Codable {
    let categories: [TransactionCategory]?
    let types: [TransactionType]?
    let statuses: [TransactionStatus]?
    let dateFrom: Date?
    let dateTo: Date?
    let minAmount: Double?
    let maxAmount: Double?
    let searchText: String?
}

// MARK: - Примеры данных для демонстрации
extension Transaction {
    static let demoTransactions: [Transaction] = [
        Transaction(
            name: "Кофе Starbucks",
            status: .completed,
            image: URL(string: "https://example.com/coffee.jpg"),
            description: "Утренний кофе",
            amount: 5.50,
            type: .payment,
            category: .food,
            date: Date().addingTimeInterval(-86400) // Вчера
        ),
        
        Transaction(
            name: "Зарплата",
            status: .received,
            image: nil,
            description: "Ежемесячная зарплата",
            amount: 2500.00,
            type: .payment,
            category: .salary,
            date: Date().addingTimeInterval(-172800) // 2 дня назад
        ),
        
        Transaction(
            name: "Межбанковский перевод",
            status: .delayed(until: Date().addingTimeInterval(3600)),
            image: nil,
            description: "Перевод между счетами",
            amount: 500.00,
            type: .transfer,
            category: .transfer,
            date: Date(),
            recipient: "John Smith"
        ),
        
        Transaction(
            name: "Оплата интернета",
            status: .pending,
            image: URL(string: "https://example.com/internet.jpg"),
            description: "Ежемесячный платеж",
            amount: 29.99,
            type: .payment,
            category: .bills,
            date: Date().addingTimeInterval(-3600) // Час назад
        ),
        
        Transaction(
            name: "Возврат товара",
            status: .refunded(amount: 45.99),
            image: nil,
            description: "Возврат в магазин",
            amount: 45.99,
            type: .refund,
            category: .shopping,
            date: Date().addingTimeInterval(-259200) // 3 дня назад
        )
    ]
}

// MARK: - Утилиты для работы с транзакциями
extension Array where Element == Transaction {
    // Фильтрация по категории
    func filterByCategory(_ category: TransactionCategory) -> [Transaction] {
        return self.filter { $0.category == category }
    }
    
    // Фильтрация по типу
    func filterByType(_ type: TransactionType) -> [Transaction] {
        return self.filter { $0.type == type }
    }
    
    // Фильтрация по статусу
    func filterByStatus(_ status: TransactionStatus) -> [Transaction] {
        return self.filter { $0.status == status }
    }
}
