//
//  Gen_FinanceApp.swift
//  Gen Finance
//
//  Created by Sandeep Kumar on 24/07/25.
//

import SwiftUI
import SwiftData

@main
struct Gen_FinanceApp: App {
    
    @State private var isActive = false
    private let SPLASH_DURATION: Double = 1.2
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if isActive {
                    ContentView()
                } else {
                    SplashScreen(duration: SPLASH_DURATION)
                }
            }
            .appTheme(PrimaryTheme())
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + SPLASH_DURATION) {
                    withAnimation {
                        self.isActive = true
                    }
                }
            }
        }
        .modelContainer(sharedModelContainer)
        
    }
}
