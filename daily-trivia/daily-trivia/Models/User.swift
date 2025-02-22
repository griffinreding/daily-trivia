//
//  User.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import Foundation
import FirebaseAuth
import GoogleSignIn

class User: Codable, Equatable {
    let email: String
    let id: String
    var username: String?
    var isFirstLogin: Bool = false
    
    init(firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email ?? ""
        self.username = nil
    }
    
    init(googleUser: GIDGoogleUser) {
        if let profile = googleUser.profile {
            self.email = profile.email
        } else {
            self.email = ""
        }
        if let id = googleUser.idToken?.tokenString {
            self.id = id
        } else {
            self.id = UUID().uuidString
        }
        
        self.username = nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.email == rhs.email
    }
}
