//
//  BankCartView.swift
//  Mones
//
//  Created by Zakhar on 30.10.25.
//


import SwiftUI

struct BankCardView: View {
    @ObservedObject var card: BankCardViewModel
    
    @State private var isFlipped = false
    
    
    var body: some View {
        ZStack {
            frontSide
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0),
                                  axis: (x: 0, y: 1, z: 0),
                                  perspective: 0.4)
            
            backSide
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180),
                                  axis: (x: 0, y: 1, z: 0),
                                  perspective: 0.4)
        }
        .frame(width: 300, height: 250)
        .shadow(radius: 20)
        .contentShape(RoundedRectangle(cornerRadius: 20))
        .onTapGesture {
            withAnimation(.spring(response: 1, dampingFraction: 0.85)) {
                isFlipped.toggle()
            }
        }
        .accessibilityAddTraits(.isButton)
        .padding(.horizontal, 20)
    }
    
    private var frontSide: some View {
        ZStack(alignment: .topLeading) {
            RoundedRectangle(cornerRadius: 20)
                .fill(.black)
            
            backgroundGradientView
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            VStack {
                Spacer()
                cardNumberView
                    .frame(maxWidth: .infinity, alignment: .center)
                Spacer()
                HStack {
                    cardHolderNameView
                    Spacer()
                    cardTypeLogoView
                }
            }
            .padding(16)
        }
    }
    
    private var backSide: some View {
        ZStack(alignment: .top) {
            RoundedRectangle(cornerRadius: 20)
                .fill(.black)
            
            backgroundGradientView
                .clipShape(RoundedRectangle(cornerRadius: 20))
            
            VStack(spacing: 30) {
                magnaticLineView
                Spacer()
                HStack(alignment: .bottom) {
                    Spacer()
                    VStack {
                        cardExpiryView
                        Spacer()
                        cvvFieldView
                    }
                    .padding(.bottom, 30)
                    .padding(.trailing, 30)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    
    // MARK: - UI Elements as computed properties
    
    private var backgroundGradientView: LinearGradient {
        LinearGradient(
            gradient: Gradient(colors: [Color.white.opacity(0.2), Color.clear]),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
    
    private var cardTypeLogoView: some View {
        HStack {
            Spacer()
            Text(card.cardType.rawValue)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.black)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.9))
                .cornerRadius(8)
        }
    }
    
    private var cardNumberView: some View {
        Text(card.formattedCardNumber) // Предполагается, что cardNumber - это свойство
            .font(.system(size: 18, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .tracking(2)
    }
    
    private var cardHolderNameView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(card.cardHolderName) // Предполагается, что cartHolderName - это свойство
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
        }
    }
    
    private var cardExpiryView: some View {
        Text(card.formattedExpirarionData) // Предполагается, что expirationDate - это свойство
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(.white)
    }
    
    private var magnaticLineView: some View {
        Rectangle()
            .fill(Color.black.opacity(0.85))
            .frame(height: 45)
            .padding(.top, 24)
            .padding(.horizontal, 0)
    }
    
    private var cvvFieldView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white)
                .frame(width: 60, height: 32)
            Text(card.cvv) // Предполагается, что cvv - это свойство
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.black)
        }
    }
}

