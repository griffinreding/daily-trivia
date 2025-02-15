//
//  AuthService.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import Foundation
import FirebaseAuth

class AuthService {
    static let shared = AuthService()
    
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
                } else if let user = authResult?.user {
                    continuation.resume(returning: User(firebaseUser: user))
                } else {
                    let unknownError = NSError(domain: "SignInError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
                    continuation.resume(throwing: unknownError)
                }
            }
        }
    }
}
