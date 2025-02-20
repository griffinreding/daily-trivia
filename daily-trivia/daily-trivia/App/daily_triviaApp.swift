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
    @StateObject private var authService = AuthService()
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            if authService.isUserLoggedIn {
                TriviaGameView()
                    .environmentObject(authService)
            } else {
                LoginView()
                    .environmentObject(authService)
                    .onOpenURL { url in
                        // Pass the URL to Google Sign-In to handle authentication callbacks.
                        let handled = GIDSignIn.sharedInstance.handle(url)
                        print("URL handled: \(handled)")
                    }
                    .onAppear {
                        if let user = Auth.auth().currentUser {
                            authService.currentUser = User(firebaseUser: user)
                        } else {
                            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                                // Check if `user` exists; otherwise, do something with `error`
                                if let user = user {
                                    authService.currentUser = User(googleUser: user)
                                }
                            }
                        }
                    }
                    .onChange(of: authService.currentUser) { user in
                        if user != nil {
                            authService.isUserLoggedIn = true
                        } else {
                            authService.isUserLoggedIn = false
                        }
                    }
            }
        }
    }
}
