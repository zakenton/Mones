//
//  TransactionTableView.swift
//  Mones
//
//  Created by Zakhar on 31.10.25.
//

import SwiftUI
//
//
//// MARK: - Ячейка транзакции

//
//// MARK: - Заголовок секции (дата)
//struct DaySectionHeader: View {
//    let date: Date
//    
//    private var title: String {
//        let cal = Calendar.current
//        if cal.isDateInToday(date) { return "Сегодня" }
//        if cal.isDateInYesterday(date) { return "Вчера" }
//        let f = DateFormatter()
//        f.dateFormat = "d MMM yyyy, EEE"
//        f.locale = Locale(identifier: "ru_RU")
//        return f.string(from: date)
//    }
//    
//    var body: some View {
//        ZStack {
//            // Фон секции
//            Rectangle()
//                .fill(Color(.systemBackground))
//                .overlay(Divider(), alignment: .bottom)
//            HStack {
//                Text(title)
//                    .font(.subheadline.bold())
//                    .foregroundStyle(.secondary)
//                Spacer()
//            }
//            .padding(.horizontal)
//            .padding(.vertical, 6)
//        }
//        .frame(height: 32)
//        .accessibilityAddTraits(.isHeader)
//    }
//}
//
//// MARK: - Таблица (отдельный компонент)
//struct TransactionTable: View {
//    let transactions: [Transaction]
//    
//    // Группировка по дню
//    private var grouped: [(day: Date, items: [Transaction])] {
//        let cal = Calendar.current
//        let groups = Dictionary(grouping: transactions) { tx in
//            cal.startOfDay(for: tx.date)
//        }
//        // Сортировка по дате (новые выше)
//        return groups
//            .map { ($0.key, $0.value.sorted { $0.date > $1.date }) }
//            .sorted { $0.0 > $1.0 }
//    }
//    
//    var body: some View {
//        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
//            ForEach(grouped, id: \.day) { group in
//                Section {
//                    ForEach(group.items) { tx in
//                        TransactionRow(tx: tx)
//                            .padding(.horizontal)
//                        Divider()
//                            .padding(.leading, 56) // чтобы линия не залезала под аватар
//                    }
//                } header: {
//                    DaySectionHeader(date: group.day)
//                }
//            }
//        }
//        .background(Color(.green))
//        .cornerRadius(20)
//        .padding(15)
//    }
//}
//
