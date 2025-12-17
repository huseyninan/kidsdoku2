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
    @State private var deepLinkProduct: String?
    
    init() {
        Purchases.logLevel = .info
        Purchases.configure(withAPIKey: "appl_frvSEfXIYrnGMynyOnMHUmlGqzo")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(deepLinkProduct: $deepLinkProduct)
                .environmentObject(appEnvironment)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "kidsdoku",
              url.host == "open",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let productParam = components.queryItems?.first(where: { $0.name == "product" })?.value else {
            return
        }
        
        deepLinkProduct = productParam
    }
}
