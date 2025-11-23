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
            
            ScrollView {
                VStack(spacing: 30) {
                    
                    CardsScreen(cardsVM: cardsViewModel)
                        
                    Group {
                        ControlView()
                        TransactionView()
                        ExchangeRateView(vm: exchangeViewModel)
                    }
                    .padding(.horizontal, 20)
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

import SwiftUI

import SwiftUI

struct CardsScreen: View {
    @ObservedObject var cardsVM: CardsViewModel
    
    var body: some View {
        
        let screenWidth = UIScreen.main.bounds.width
        
        VStack(spacing: 16) {
            TabView(selection: $cardsVM.selectedIndex) {
                ForEach(cardsVM.cards.indices, id: \.self) { index in
                    BankCardView(card: cardsVM.cards[index].viewModel)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(width: screenWidth, height: 340)
            
            CardSliderIndicator(
                count: cardsVM.cards.count,
                currentIndex: cardsVM.selectedIndex
            )
            .padding(.horizontal, 60)
        }
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
    return HomeView()
}
