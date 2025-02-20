//
//  AppState.swift
//  daily-trivia
//
//  Created by GReding on 2/18/25.
//


import SwiftUI
import FirebaseAuth
import GoogleSignIn

@MainActor
class AppState: ObservableObject {
    public static let shared = AppState()
    \
    //maybe scrap all this, move it to the authservice, and make it an environment object, using the window group
    //and navigation view you just found

    @Published var isUserLoggedIn: Bool = false
    @Published var currentUser: User?
    
    init() {
        Auth.auth().addStateDidChangeListener { auth, user in
            if let user = user {
                self.currentUser = User(firebaseUser: user)
            } else {
                self.currentUser = nil
            }
        }
    }
    
    @MainActor
    func logout() throws {
        if GIDSignIn.sharedInstance.currentUser != nil {
            GIDSignIn.sharedInstance.signOut()
            print("Signed out of Google account.")
        }
        
        try Auth.auth().signOut()
        currentUser = nil
    }
}
