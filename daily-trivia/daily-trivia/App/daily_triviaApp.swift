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
    @StateObject var appState = AppState()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if appState.isUserLoggedIn {
                TriviaGameView()
                    .environmentObject(appState)
            } else {
                LoginView()
                    .environmentObject(appState)
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
        }
    }
}
