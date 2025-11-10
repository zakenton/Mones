//
//  ConvexButton.swift
//  Mones
//
//  Created by Zakhar on 30.10.25.
//

import SwiftUI

struct ConvexButton: View {
    let systemName: String
    let action: () -> Void
    var size: CGFloat = 64
    var base: Color = Color(.systemGray6)
    var lightAngle: Angle = .degrees(135) // (↖︎)

    var body: some View {
        Button {
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            action()
        } label: {
            Image(systemName: systemName)
                .font(.system(size: size * 0.36, weight: .semibold))
                .foregroundStyle(.gray.opacity(0.9))
                .frame(width: size, height: size)
        }
        .buttonStyle(ConvexCircleStyle(size: size, base: base, lightAngle: lightAngle))
    }
}

struct ConvexCircleStyle: ButtonStyle {
    var size: CGFloat
    var base: Color
    var lightAngle: Angle

    func makeBody(configuration: Configuration) -> some View {
        let pressed = configuration.isPressed

        let dx = CGFloat(cos(lightAngle.radians)) * (pressed ? 3 : 8)
        let dy = CGFloat(sin(lightAngle.radians)) * (pressed ? 3 : 8)

        let shape = Circle()

        return configuration.label
            .background(
                ZStack {
                    // 1) база — мягкий градиент (без внешнего белого свечения)
                    shape.fill(
                        LinearGradient(
                            colors: [base.lighten(0.06), base.darken(0.05)],
                            startPoint: .topLeading, endPoint: .bottomTrailing
                        )
                    )

                    // 2) внутренний спекулярный блик (замена "ореола")
                    shape
                        .fill(
                            RadialGradient(
                                colors: [Color.white.opacity(0.5), .clear],
                                center: .topLeading, startRadius: 0, endRadius: size * 0.9
                            )
                        )
                        .opacity(pressed ? 0.22 : 0.45)

                    // 3) тонкий внутренний рим (слегка «стеклянный» край)
                    shape
                        .stroke(base.lighten(0.18).opacity(0.45), lineWidth: 0.7)
                        .blendMode(.overlay)
                }
                // 4) только одна внешняя (тёмная) направленная тень — без белого ореола
                .shadow(color: .black.opacity(pressed ? 0.1 : 0.18),
                        radius: pressed ? 6 : 12,
                        x: dx, y: dy)
                // 5) инсет-тени при нажатии (эффект вдавливания)
                .overlay(
                    Group {
                        if pressed {
                            shape
                                .stroke(Color.black.opacity(0.22), lineWidth: 3)
                                .blur(radius: 3)
                                .offset(x: dx/3, y: dy/3)
                                .mask(shape.fill(
                                    LinearGradient(colors: [.black, .clear],
                                                   startPoint: .bottomTrailing, endPoint: .center)
                                ))

                            shape
                                .stroke(Color.white.opacity(0.7), lineWidth: 3)
                                .blur(radius: 3)
                                .offset(x: -dx/3, y: -dy/3)
                                .mask(shape.fill(
                                    LinearGradient(colors: [.white, .clear],
                                                   startPoint: .topLeading, endPoint: .center)
                                ))
                        }
                    }
                )
            )
            .scaleEffect(pressed ? 0.97 : 1)
            .animation(.spring(response: 0.28, dampingFraction: 0.85), value: pressed)
            .contentShape(Circle())
    }
}

// MARK: - цветовые утилиты
private extension Color {
    func lighten(_ k: CGFloat) -> Color { blend(with: .white, amount: k) }
    func darken(_ k: CGFloat) -> Color { blend(with: .black, amount: k) }
    func blend(with other: Color, amount: CGFloat) -> Color {
        let a = max(0, min(1, amount))
        return Color(uiColor: UIColor(self).blend(with: UIColor(other), amount: a))
    }
}
private extension UIColor {
    convenience init(_ c: Color) { self.init(cgColor: c.cgColor ?? UIColor.white.cgColor) }
    func blend(with other: UIColor, amount: CGFloat) -> UIColor {
        var r1: CGFloat=0,g1:CGFloat=0,b1:CGFloat=0,a1:CGFloat=0
        var r2: CGFloat=0,g2:CGFloat=0,b2:CGFloat=0,a2:CGFloat=0
        getRed(&r1,green: &g1,blue: &b1,alpha: &a1); other.getRed(&r2,green: &g2,blue: &b2,alpha: &a2)
        return UIColor(red: r1+(r2-r1)*amount,
                       green: g1+(g2-g1)*amount,
                       blue: b1+(b2-b1)*amount,
                       alpha: a1+(a2-a1)*amount)
    }
}

