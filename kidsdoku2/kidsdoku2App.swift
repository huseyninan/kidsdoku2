//
//  kidsdoku2App.swift
//  kidsdoku2
//
//  Created by hinan on 30.10.2025.
//

import SwiftUI
import RevenueCat
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct kidsdoku2App: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appEnvironment = AppEnvironment()
    
    init() {
        Purchases.logLevel = .info
        Purchases.configure(withAPIKey: "appl_frvSEfXIYrnGMynyOnMHUmlGqzo")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appEnvironment)
        }
    }
}
