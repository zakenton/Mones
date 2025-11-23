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
    @State private var showCVV: Bool = false
    @State private var showCardNumber: Bool = false
    
    private enum Layout {
        static let aspectRatio: CGFloat = 1.586
        static let cornerRadius: CGFloat = 20
    }
    
    var body: some View {
        ZStack {
            frontSide
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(
                    .degrees(isFlipped ? 180 : 0),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.4
                )
            
            backSide
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(
                    .degrees(isFlipped ? 0 : -180),
                    axis: (x: 0, y: 1, z: 0),
                    perspective: 0.4
                )
        }
        .aspectRatio(Layout.aspectRatio, contentMode: .fit)
        .frame(maxWidth: 340)
        .shadow(radius: 20)
        .contentShape(RoundedRectangle(cornerRadius: Layout.cornerRadius))
        .onTapGesture {
            withAnimation(.spring(response: 1, dampingFraction: 0.85)) {
                isFlipped.toggle()
            }
        }
        .accessibilityAddTraits(.isButton)
        .padding(.horizontal, 20)
    }
}

// MARK: - Card Faces
private extension BankCardView {
    
    var frontSide: some View {
        ZStack(alignment: .topLeading) {
            cardBackground
            
            VStack {
                Spacer()
                
                cardNumberView
                    .frame(maxWidth: .infinity, alignment: .center)
                    .onTapGesture {
                        showCardNumber.toggle()
                    }
                
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
    
    var backSide: some View {
        ZStack(alignment: .top) {
            cardBackground
            
            VStack(spacing: 30) {
                magneticLineView
                Spacer()
                
                HStack(alignment: .bottom) {
                    Spacer()
                    
                    VStack {
                        cardExpiryView
                        Spacer()
                        cvvFieldView
                            .onTapGesture {
                                showCVV.toggle()
                            }
                    }
                    .padding(.bottom, 30)
                    .padding(.trailing, 30)
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius))
    }
}

// MARK: - Building Blocks

private extension BankCardView {
    
    var cardBackground: some View {
        RoundedRectangle(cornerRadius: Layout.cornerRadius)
            .fill(Color.black)
            .overlay(
                LinearGradient(
                    gradient: Gradient(colors: [Color.white.opacity(0.2), .clear]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: Layout.cornerRadius))
            )
    }
    
    var cardTypeLogoView: some View {
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
    
    var cardNumberView: some View {
        Text(showCardNumber ? card.formattedCardNumber : card.maskedCardNumber)
            .font(.system(size: 18, weight: .bold, design: .monospaced))
            .foregroundColor(.white)
            .tracking(2)
    }
    
    var cardHolderNameView: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(card.cardHolderName)
                .font(.system(size: 18, weight: .medium, design: .rounded))
                .foregroundStyle(.white)
        }
    }
    
    var cardExpiryView: some View {
        Text(card.formattedExpirationDate)
            .font(.system(size: 16, weight: .medium, design: .rounded))
            .foregroundColor(.white)
    }
    
    var magneticLineView: some View {
        Rectangle()
            .fill(Color.black.opacity(0.85))
            .frame(height: 45)
            .padding(.top, 24)
            .padding(.horizontal, 0)
    }
    
    var cvvFieldView: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white)
                .frame(width: 60, height: 32)
            
            Text(showCVV ? card.cvv : card.maskedCVV)
                .font(.system(size: 14, weight: .medium, design: .monospaced))
                .foregroundColor(.black)
        }
    }
}
