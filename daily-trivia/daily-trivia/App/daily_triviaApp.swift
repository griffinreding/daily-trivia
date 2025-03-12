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
                        let handled = GIDSignIn.sharedInstance.handle(url)
                        print("URL handled: \(handled)")
                    }
                    .onAppear {
                        if let user = Auth.auth().currentUser {
                            Task {
                                do {
                                    authService.currentUser = User(firebaseUser: user)
                                    try await authService.fetchUsername(forEmail: user.email ?? "")
                                    try await authService.fetchUserStreak()
                                }
                                catch {
                                    print("Error signing in with Firebase: \(error.localizedDescription)")
                                    return //need a better solution here
                                }
                            }
                        }
                        else {
                            GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                                Task {
                                    do {
                                        if let user = user {
                                            authService.currentUser = User(googleUser: user)
                                            try await authService.fetchUsername(forEmail: user.profile?.email ?? "")
                                            try await authService.fetchUserStreak()
                                        }
                                    } catch {
                                        print("Error signing in with Google: \(error.localizedDescription)")
                                        return //need a better solution here
                                    }
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
