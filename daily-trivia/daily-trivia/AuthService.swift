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

class AuthService {
    static let shared = AuthService()
    var currentUser: User?
    
    init() {
        if let firebaseUser = Auth.auth().currentUser {
            currentUser = User(firebaseUser: firebaseUser)
        } else {
            currentUser = nil
        }
    }
    
    //do this for creating an account in firebase instead using firestore
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Sign Up Error: \(error.localizedDescription)")
            } else {
                print("User signed up with uid: \(result?.user.uid ?? "")")
            }
        }
    }
    
    func signIn(email: String, password: String) async throws -> User {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    print("Login error: \(error.localizedDescription)")
                } else if let user = authResult?.user {
                    continuation.resume(returning: User(firebaseUser: user))
                } else {
                    let unknownError = NSError(domain: "SignInError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
                    print("Unknown login error: \(unknownError.localizedDescription)")
                    continuation.resume(throwing: unknownError)
                }
            }
        }
    }
    
    func createUserAccountIfNeeded(for firebaseUser: FirebaseAuth.User) async throws {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(firebaseUser.uid)
        
        let snapshot = try await userRef.getDocumentAsync()
        if snapshot.exists {
            print("User document already exists.")
            return
        } else {
            let userData: [String: Any] = [
                "email": firebaseUser.email ?? "",
                "displayName": firebaseUser.displayName ?? "",
                "createdAt": FieldValue.serverTimestamp()
                // Add additional default fields as needed.
            ]
            try await userRef.setDataAsync(userData)
            print("User document successfully created!")
        }
    }
    
    func createUserAccountFromGoogleIfNeeded(for googleUser: GIDGoogleUser) async throws {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(googleUser.profile?.email ?? "this won't be found")
        
        let snapshot = try await userRef.getDocumentAsync()
        
        
        if snapshot.exists {
            //this works, user already exists
            let user = try snapshot.data(as: User.self)
            
            print("User document already exists for \(user.email)")
            return
        } else {
            var id: String
            
            if let googleToken = googleUser.idToken?.tokenString {
                id = googleToken
            } else {
                id = UUID().uuidString
            }
            
            let userData: [String: Any] = [
                "email": googleUser.profile?.email ?? "",
                "id": id,
                "createdAt": FieldValue.serverTimestamp()
            ]
            try await userRef.setDataAsync(userData)
            print("User document successfully created!")
        }
    }
        
}
