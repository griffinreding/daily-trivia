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
    
    var body: some Scene {
        WindowGroup {
            if appState.isUserLoggedIn {
                TriviaGameView()
            } else {
                LoginView()
                    .environmentObject(AppState.shared)
                    .onOpenURL { url in
                        // Pass the URL to Google Sign-In to handle authentication callbacks.
                        let handled = GIDSignIn.sharedInstance.handle(url)
                        print("URL handled: \(handled)")
                    }
                    .onAppear {
                        if let user = Auth.auth().currentUser {
                            appState.currentUser = User(firebaseUser: user)
                        } else {
                            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                                // Check if `user` exists; otherwise, do something with `error`
                                if let user = user {
                                    appState.currentUser = User(googleUser: user)
                                }
                            }
                        }
                    }
                    .onChange(of: appState.currentUser) { user in
                        if user != nil {
                            appState.isUserLoggedIn = true
                        } else {
                            appState.isUserLoggedIn = false
                        }
                    }
            }
        }
    }
}
