//
//  AuthView.swift
//  Mones
//
//  Created by Zakhar on 06.11.25.
//

import SwiftUI

struct LockScreen: View {
    @ObservedObject var authModel: LockManager

    private let rows: [[String]] = [
        ["1","2","3"],
        ["4","5","6"],
        ["7","8","9"]
    ]

    var body: some View {
        VStack(spacing: 30) {
            HStack(spacing: 16) {
                ForEach(0..<4, id: \.self) { index in
                    ProgressPointView(isFilled: index < authModel.userCodeInput.count)
                }
            }
            .padding(.top, 50)

            VStack(spacing: 20) {
                ForEach(rows, id: \.self) { row in
                    KeypadRow(numbers: row, tap: authModel.setSymbol)
                }

                HStack(spacing: 20) {
                    UniversalButton(.faceId(action: authModel.resetPasscode))
                    UniversalButton(.auth(number: "0", action: authModel.setSymbol))
                    UniversalButton(.back(action: authModel.removeLast))
                }
            }

            Spacer()
        }
        .padding()
    }
}

private struct KeypadRow: View {
    let numbers: [String]
    let tap: (String) -> Void

    var body: some View {
        HStack(spacing: 20) {
            ForEach(numbers, id: \.self) { n in
                UniversalButton(.auth(number: n, action: tap))
            }
        }
    }
}

private struct ProgressPointView: View {
    let isFilled: Bool
    @Environment(\.colorScheme) private var colorScheme

    private var fillColor: Color { colorScheme == .dark ? .white : .black }

    var body: some View {
        Circle()
            .strokeBorder(.primary, lineWidth: 2)
            .background(
                Circle().fill(isFilled ? fillColor : .clear)
            )
            .frame(width: 20, height: 20)
    }
}

#Preview {
    LockScreen(authModel: LockManager())
}

