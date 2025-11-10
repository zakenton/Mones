//
//  MonesApp.swift
//  Mones
//
//  Created by Zakhar on 26.10.25.
//

import SwiftUI
import SwiftData

@main
struct MonesApp: App {
    
    @StateObject private var lock = LockManager()
    @Environment(\.scenePhase) private var phase
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(lock)
                .fullScreenCover(isPresented: isLockedBinding) {
                    LockScreen(authModel: lock)
                }
                .onChange(of: phase) { _, newPhase in
                    if newPhase == .background {
                        lock.lock()
                    }
                }
        }
    }
    
    private var isLockedBinding: Binding<Bool> {
        Binding(
            get: {lock.state == .locked},
            set: { _ in }
        )
    }
}
