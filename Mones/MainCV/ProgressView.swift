//
//  ProgressView.swift
//  Mones
//
//  Created by Zakhar on 30.10.25.
//

import SwiftUI

struct ProgressView: View {
    @Binding var progress: Float
    
    var body: some View {
        ZStack {
            // Фоновая дуга
            GaugeArc()
                .stroke(style: StrokeStyle(lineWidth: 15, lineCap: .round))
                .frame(width: 150, height: 150)
                .foregroundStyle(.gray.opacity(0.2))
            
            // Прогресс дуга
            GaugeArc()
                .trim(from: 0, to: CGFloat(min(progress, 1.0))) // Ограничиваем максимум 1.0
                .stroke(style: StrokeStyle(lineWidth: 18, lineCap: .round, lineJoin: .round))
                .frame(width: 150, height: 150)
                .animation(.easeInOut, value: progress)
        }
    }
}

struct GaugeArc: InsettableShape {
    var startAngle: Angle = .degrees(150) // bottom-left
    var endAngle: Angle = .degrees(30)   // bottom-right
    var insetAmount: CGFloat = 0
    
    func path(in rect: CGRect) -> Path {
        let radius = min(rect.width, rect.height) / 2 - insetAmount
        let center = CGPoint(x: rect.midX, y: rect.midY)
        var p = Path()
        p.addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        return p
    }
    
    func inset(by amount: CGFloat) -> some InsettableShape {
        var copy = self
        copy.insetAmount += amount
        return copy
    }
}
