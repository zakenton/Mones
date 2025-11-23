//
//  TransactionView.swift
//  Mones
//
//  Created by Zakhar on 17.11.25.
//

import Foundation
import SwiftUI

struct TransactionView: View {
    let transactions = [
        Transaction(name: "Some Coffee",
                    status: .completed,
                    description: "some description",
                    amount: 100,
                    type: .payment,
                    category: .food),
        Transaction(name: "Some Coffee",
                    status: .completed,
                    description: "some description",
                    amount: 100,
                    type: .deposit,
                    category: .food),
        Transaction(name: "Work",
                    status: .completed,
                    description: "some description",
                    amount: 2000.00,
                    type: .deposit,
                    category: .bills),
    ]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Transaction")
                .font(.system(size: 20, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
            
            TransactionRow(tx: transactions[0])
            TransactionRow(tx: transactions[1])
            TransactionRow(tx: transactions[2])
        }
        .padding(20)
        .applyGlassEffect()
    }
}

struct TransactionRow: View {
    let tx: Transaction

    var body: some View {
        HStack(spacing: 12) {
            image
            name
            Spacer()
            amount
        }
        .padding(.vertical, 8)
        .contentShape(Rectangle())
    }
    
    private var image: some View {
        Image(systemName: "plus")
            .resizable()
            .scaledToFit()
            .frame(width: 36, height: 36)
            .padding(8)
            .background(
                Circle().fill(Color(.secondarySystemBackground))
            )
    }
    
    private var name: some View {
        Text(tx.name)
            .font(.headline)
            .lineLimit(1)
    }
    
    private var amount: some View {
        Text(tx.amountWithSign)
            .font(.headline)
            .foregroundColor(tx.amountColor)
            .monospacedDigit()
            .lineLimit(1)
    }
}
