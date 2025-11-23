//
//  CardSliderIndicator.swift
//  Mones
//
//  Created by Zakhar on 22.11.25.
//

import Foundation
import SwiftUI

import SwiftUI

struct CardSliderIndicator: View {
    let count: Int          // сколько карт всего
    let currentIndex: Int   // индекс выбранной карты (0...count-1)
    
    @Environment(\.colorScheme) private var colorScheme
    @State private var isMoving = false
    
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let height = geo.size.height
            
            let trackHeight = height
            let thumbDiameter = height
            let stretchFactor: CGFloat = 1.8
            let clampedCount = max(count, 1)
            let safeIndex = min(max(currentIndex, 0), clampedCount - 1)
            
            let step = clampedCount > 1
                ? (width - thumbDiameter) / CGFloat(clampedCount - 1)
                : 0
            
            // смещение ползунка по X
            let offsetX = step * CGFloat(safeIndex)
            
            ZStack(alignment: .leading) {
                // Трек
                Capsule()
                    .fill(trackColor)
                    .frame(height: trackHeight)
                
                // Ползунок
                Capsule()
                    .fill(thumbColor)
                    .frame(
                        width: thumbDiameter * (isMoving ? stretchFactor : 1.0),
                        height: thumbDiameter
                    )
                    .shadow(radius: 3, y: 1)
                    .offset(x: offsetX)
                    .animation(
                        .spring(response: 0.45, dampingFraction: 0.75),
                        value: offsetX
                    )
                    .animation(
                        .easeOut(duration: 0.25),
                        value: isMoving
                    )
            }
        }
        .frame(height: 24)
        .onChange(of: currentIndex) { _ in
            isMoving = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                isMoving = false
            }
        }
    }
    
    private var trackColor: Color {
        colorScheme == .dark
        ? .white.opacity(0.25)
        : .black.opacity(0.12)
    }
    
    private var thumbColor: Color {
        colorScheme == .dark ? .white : .black
    }
}


// MARK: - Demo View for Preview

struct CardSliderIndicatorDemoView: View {
    @State private var selectedIndex: Int = 0
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Selected card: \(selectedIndex + 1)")
                .font(.headline)
            
            CardSliderIndicator(
                count: 3,
                currentIndex: selectedIndex
            )
            .padding(.horizontal, 40)
            
            Picker("Card", selection: $selectedIndex) {
                Text("1").tag(0)
                Text("2").tag(1)
                Text("3").tag(2)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding(.top, 40)
    }
}

// MARK: - Preview

struct CardSliderIndicator_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardSliderIndicatorDemoView()
                .previewDisplayName("Light")
            
            CardSliderIndicatorDemoView()
                .preferredColorScheme(.dark)
                .previewDisplayName("Dark")
        }
    }
}
