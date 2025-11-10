//
//  FlipCard.swift
//  Mones
//
//  Created by Zakhar on 30.10.25.
//

import SwiftUI

struct FlipCard: View {
    @State private var isFlipped = false
    var arr = Array<Int>(arrayLiteral: 1,2,3)
    var opt = Optional<Int>(1)

    var body: some View {
        ZStack {
            // Лицевая сторона (красная)
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.red)
                .overlay(Text("RED").font(.title).bold().foregroundStyle(.white))
                .opacity(isFlipped ? 0 : 1)
                .rotation3DEffect(.degrees(isFlipped ? 180 : 0),
                                  axis: (x: 0, y: 1, z: 0))

            // Обратная сторона (зелёная) — заранее повернута на 180°
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.green)
                .overlay(Text("GREEN").font(.title).bold().foregroundStyle(.white))
                .opacity(isFlipped ? 1 : 0)
                .rotation3DEffect(.degrees(isFlipped ? 0 : -180),
                                  axis: (x: 0, y: 1, z: 0))
        }
        .frame(width: 240, height: 160)
        .shadow(radius: 12)
        // Общая 3D-перспектива + жест
        .rotation3DEffect(.degrees(0), axis: (0, 1, 0), perspective: 0.6)
        .onTapGesture {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
                isFlipped.toggle()
            }
        }
    }
}

#Preview {
    FlipCard()
}
