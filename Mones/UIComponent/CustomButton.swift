//
//  CustomButton.swift
//  Mones
//
//  Created by Zakhar on 06.11.25.
//

import SwiftUI

import SwiftUI

enum ButtonType {
    case auth(number: String, action: (String) -> Void)
    case control(systemName: String, action: () -> Void)
    case faceId(action: () -> Void)
    case back(action: () -> Void)
}

struct UniversalButton: View {
    let type: ButtonType
    
    init(_ type: ButtonType) {
        self.type = type
    }

    var body: some View {
        Button {
            #if os(iOS)
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            #endif
            switch type {
            case .auth(let number, let action):
                action(number)
            case .control(_, let action):
                action()
            case .faceId(let action):
                action()
            case .back(let action):
                action()
            }
        } label: {
            switch type {
            case .auth(let number, _):
                Text(number)
                    .font(.system(size: 26, weight: .semibold, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(width: 70, height: 70)
                    .background(
                        Circle()
                            .fill(.regularMaterial)
                            .shadow(color: .black.opacity(0.25), radius: 3, x: 0, y: 2)
                    )
            case .control(let systemName, _):
                Image(systemName: systemName)
                    .font(.system(size: 26, weight: .semibold))
                    .foregroundColor(.gray)
                    .frame(width: 64, height: 64)
                    .background(
                        Circle()
                            .fill(Color(.systemGray6))
                            .shadow(color: .black.opacity(0.15), radius: 6, x: 4, y: 4)
                            .shadow(color: .white.opacity(0.8), radius: 6, x: -4, y: -4)
                    )
            case .faceId(_):
                Image(systemName: "faceid")
                    .font(.system(size: 35, weight: .semibold))
                    .foregroundStyle(.gray)
                    .frame(width: 64, height: 64)
            case .back(_):
                Image(systemName: "delete.left.fill")
                    .font(.system(size: 35, weight: .semibold))
                    .foregroundStyle(.gray)
                    .frame(width: 64, height: 64)
            }
        }
        .buttonStyle(PressAnimationStyle())
    }
}


struct PressAnimationStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.94 : 1)
            .opacity(configuration.isPressed ? 0.9 : 1)
            .animation(.easeOut(duration: 0.1), value: configuration.isPressed)
    }
}
