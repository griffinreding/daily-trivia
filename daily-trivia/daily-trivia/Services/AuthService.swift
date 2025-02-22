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


    //do this for creating an account in firebase instead using firestore
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
        let userRef = db.collection("users").document(firebaseUser.email ?? "this won't be found")
        
        let snapshot = try await userRef.getDocumentAsync()
        if snapshot.exists {
            print("User document already exists.")
            return
        } else {
            let userData: [String: Any] = [
                "email": firebaseUser.email ?? "",
                "id": firebaseUser.email ?? "",
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
        let userRef = db.collection("users").document(googleUser.profile?.email ?? "this won't be found")
        
        //current offender of google log in issues for existing users
        let snapshot = try await userRef.getDocumentAsync()
        
        
        if snapshot.exists {
            let user = try snapshot.data(as: User.self)
            
            self.currentUser = user
            
            let username = try await self.fetchUsername(forEmail: googleUser.profile?.email ?? "")
            self.currentUser?.username = username
            
            print("User document already exists for \(user.email)")
        } else {
            let userData: [String: Any] = [
                "email": googleUser.profile?.email ?? "",
                "id": googleUser.profile?.email ?? "",
                "createdAt": FieldValue.serverTimestamp()
            ]
            try await userRef.setDataAsync(userData)
            
            self.currentUser = User(googleUser: googleUser)
            self.currentUser?.isFirstLogin = true
            
            print("User document successfully created!")
        }
    }
    
    func fetchUsername(forEmail email: String) async throws -> String? {
        let db = Firestore.firestore()
        
        let docRef = db.collection("users").document(email)
        
        do {
            let documentSnapshot = try await docRef.getDocument()
            
            if let data = documentSnapshot.data(),
               let username = data["username"] as? String {
                return username
            } else {
                print("No user found for email: \(email)")
                return nil
            }
        } catch {
            print("Error fetching user: \(error.localizedDescription)")
            throw error
        }
    }
}
