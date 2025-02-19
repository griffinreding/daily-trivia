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
    
    init(firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email ?? ""
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
    }
    
    //make this conform to equatable by comparing emails
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.email == rhs.email
    }
}
