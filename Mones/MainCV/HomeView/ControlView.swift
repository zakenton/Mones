//
//  ControlView.swift
//  Mones
//
//  Created by Zakhar on 17.11.25.
//

import Foundation
import SwiftUI

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
