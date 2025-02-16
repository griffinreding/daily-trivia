//
//  daily_triviaApp.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import SwiftUI
import SwiftData
import Firebase
import GoogleSignIn

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
            LoginView()
                .onOpenURL { url in
                    // Pass the URL to Google Sign-In to handle authentication callbacks.
                    let handled = GIDSignIn.sharedInstance.handle(url)
                    print("URL handled: \(handled)")
                }
                .onAppear {
                    if let user = Auth.auth().currentUser {
                        AuthService.shared.currentUser = User(firebaseUser: user)
                    } else {
                        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                            // Check if `user` exists; otherwise, do something with `error`
                            if let user = user {
                                AuthService.shared.currentUser = User(googleUser: user)
                            }
                        }
                    }
                }
        }
        .modelContainer(sharedModelContainer)
        
    }
}
