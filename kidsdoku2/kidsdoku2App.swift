//
//  kidsdoku2App.swift
//  kidsdoku2
//
//  Created by hinan on 30.10.2025.
//

import SwiftUI
import RevenueCat

@main
struct kidsdoku2App: App {
    @StateObject private var appEnvironment = AppEnvironment()
    
    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_frvSEfXIYrnGMynyOnMHUmlGqzo")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appEnvironment)
        }
    }
}
