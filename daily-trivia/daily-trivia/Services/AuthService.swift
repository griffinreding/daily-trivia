//
//  AuthService.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn
import SwiftUI

class AuthService: ObservableObject {
    @Published var isUserLoggedIn: Bool = false
    @Published var currentUser: User?
    
    @MainActor
    func logout() throws {
        if GIDSignIn.sharedInstance.currentUser != nil {
            GIDSignIn.sharedInstance.signOut()
            print("Signed out of Google account.")
        }
        
        currentUser = nil
        isUserLoggedIn = false
        try Auth.auth().signOut()
    }

    @MainActor
    func signUp(email: String, password: String) async throws -> Bool {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    print("Sign Up Error: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                } else {
                    print("User signed up with uid: \(result?.user.uid ?? "")")
                    continuation.resume(returning: true)
                }
            }
        }
    }
    
    @MainActor
    func signIn(email: String, password: String) async throws -> Firebase.User {
        try await withCheckedThrowingContinuation { continuation in
            
            
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    print("Login error: \(error.localizedDescription)")
                } else if let user = authResult?.user {
                    Task {
                        self.currentUser = User(firebaseUser: user)
                        continuation.resume(returning: user)
                    }
                } else {
                    let unknownError = NSError(domain: "SignInError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
                    print("Unknown login error: \(unknownError.localizedDescription)")
                    continuation.resume(throwing: unknownError)
                }
            }
        }
    }
    
    @MainActor
    func createUserAccountIfNeeded(for firebaseUser: FirebaseAuth.User) async throws {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(firebaseUser.email?.sanitizedEmail() ?? "this won't be found")
        
        let snapshot = try await userRef.getDocumentAsync()
        if snapshot.exists {
            let user = try snapshot.data(as: User.self)
            
            self.currentUser = user
            
            print("User document already exists.")
            return
        } else {
            let userData: [String: Any] = [
                "email": firebaseUser.email?.sanitizedEmail() ?? "",
                "id": firebaseUser.email?.sanitizedEmail() ?? "",
                "createdAt": FieldValue.serverTimestamp()
                // Add additional default fields as needed.
            ]
            try await userRef.setDataAsync(userData)
            print("User document successfully created!")
        }
    }
    
    @MainActor
    func createUserAccountFromGoogleIfNeeded(for googleUser: GIDGoogleUser) async throws {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(googleUser.profile?.email.sanitizedEmail() ?? "this won't be found")
        let snapshot = try await userRef.getDocumentAsync()
        
        if snapshot.exists {
            let user = try snapshot.data(as: User.self)
            
            self.currentUser = user
//            self.
            
            try await self.fetchUsername(forEmail: googleUser.profile?.email.sanitizedEmail() ?? "")
            
            print("User document already exists for \(user.email.sanitizedEmail())")
        } else {
            let userData: [String: Any] = [
                "email": googleUser.profile?.email.sanitizedEmail() ?? "",
                "id": googleUser.profile?.email.sanitizedEmail() ?? "",
                "createdAt": FieldValue.serverTimestamp()
            ]
            try await userRef.setDataAsync(userData)
            
            self.currentUser = User(googleUser: googleUser)
            self.currentUser?.streak = 0
            
            print("User document successfully created!")
        }
    }
    
    func submitUsername(username: String) async throws {
        guard let userEmail = currentUser?.email.sanitizedEmail() else {
            throw NSError(domain: "UserError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User email not available."])
        }
        
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(userEmail)

        try await userDocRef.setData(["username": username], merge: true)
        currentUser?.username = username
    }
    
    func fetchUsername(forEmail email: String) async throws {
        let db = Firestore.firestore()
        
        let docRef = db.collection("users").document(email.sanitizedEmail())
        
        do {
            let documentSnapshot = try await docRef.getDocument()
            
            if let data = documentSnapshot.data(), let username = data["username"] as? String {
                self.currentUser?.username = username
                print("Username found and assigned: \(username)")
            } else {
                print("No user found for email: \(email.sanitizedEmail())")
            }
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
            throw error
        }
    }
    
    func fetchUserStreak(forUsername username: String) async throws {
        let db = Firestore.firestore()
        
        let docRef = db.collection("users").document(username)
        
        do {
            let documentSnapshot = try await docRef.getDocument()
            
            if let data = documentSnapshot.data(), let streak = data["streak"] as? Int {
                //TODO: call a function here to set the streak to zero if they don't have an answer for yesterday
                self.currentUser?.streak = streak
            } else {
                try await self.updateCurrentUsersStreak(streak: 0)
            }
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
            throw error
        }
    }



    
    func updateCurrentUsersStreak(streak: Int) async throws {
        guard let userEmail = currentUser?.email.sanitizedEmail() else {
            throw NSError(domain: "UserError", code: 0, userInfo: [NSLocalizedDescriptionKey: "User email not available."])
        }
        
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(userEmail)
        
        try await userDocRef.setData(["streak": streak], merge: true)
        currentUser?.streak = streak
    }


}
