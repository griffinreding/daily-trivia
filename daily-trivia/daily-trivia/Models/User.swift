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
    
    init(firebaseUser: FirebaseAuth.User) {
        self.id = firebaseUser.uid
        self.email = firebaseUser.email?.sanitizedEmail() ?? ""
        self.username = nil
    }
    
    init(googleUser: GIDGoogleUser) {
        self.id = googleUser.profile?.email.sanitizedEmail() ?? ""
        self.email = googleUser.profile?.email.sanitizedEmail() ?? ""
        self.username = nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.email == rhs.email
    }
}
