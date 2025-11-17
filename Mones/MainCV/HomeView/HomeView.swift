//
//  ContentView.swift
//  Mones
//
//  Created by Zakhar on 26.10.25.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var gradientAnimation = true
    @StateObject private var cardsViewModel = CardsViewModel()
    @StateObject private var exchangeViewModel = ExchangeViewModel()
    
    var body: some View {
        ZStack {
            AnimatedGradientBackground()
            VStack {
                ScrollView() {
                    VStack(alignment: .center, spacing: 30) {
                        Text(exchangeViewModel.firstCurrencyRate)
                        BankCardView(card: CardsViewModel.mock.selectedCard!)
                        .padding()
                        ControlView()
                        
                        TransactionView()
                            .padding(.horizontal, 20)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                gradientAnimation.toggle()
            }
        }
    }
}

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

struct ControlView: View {
    var body: some View {
        HStack(spacing: 20) {
            UniversalButton(.control(systemName: "paperplane", action: mokfunc))
            UniversalButton(.control(systemName: "plus.app", action: mokfunc))
            UniversalButton(.control(systemName: "text.document.fill", action: mokfunc))
            UniversalButton(.control(systemName: "calendar.badge.clock", action: mokfunc))
        }
        .padding(15)
        .applyGlassEffect()
    }
    
    func mokfunc() {
        
    }
}

struct AnimatedGradientBackground: View {
    @State private var gradientAnimation = true
    
    let colors: [Color]
    
    init(colors: [Color] = [
        Color(red: 0.8, green: 0.8, blue: 0.8),
        Color(red: 0.8, green: 0.8, blue: 0.8),
        Color(red: 0.5, green: 0.5, blue: 0.5),
        Color(red: 0.2, green: 0.2, blue: 0.2)
    ]) {
        self.colors = colors
    }
    
    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: gradientAnimation ? .topLeading : .topTrailing,
            endPoint: gradientAnimation ? .bottomTrailing : .bottomLeading
        )
        .ignoresSafeArea()
        .onAppear {
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
                gradientAnimation.toggle()
            }
        }
    }
}

// Модификатор для glass effect
// Модификатор для glass effect с fallback на тень
extension View {
    @ViewBuilder
    func applyGlassEffect() -> some View {
        if #available(iOS 26.0, *) {
            self.glassEffect(.clear, in: RoundedRectangle(cornerRadius:20))
        } else {
            self
                .background(Color.clear) // Прозрачный фон
                .shadow(
                    color: .black.opacity(0.1),
                    radius: 8,
                    x: 0,
                    y: 4
                )
                .shadow(
                    color: .black.opacity(0.05),
                    radius: 2,
                    x: 0,
                    y: 1
                )
        }
    }
}

#Preview {
    // Build a temporary in-memory container for preview
    return HomeView()
}
