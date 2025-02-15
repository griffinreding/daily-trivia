//
//  daily_triviaApp.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import SwiftUI
import SwiftData
import Firebase

@main
struct daily_triviaApp: App {
    
    init() {
        FirebaseApp.configure()
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
