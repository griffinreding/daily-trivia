//
//  User.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import Foundation
import FirebaseAuth

class User: Codable {
    let email: String
    let id: UUID
    
    init(firebaseUser: FirebaseAuth.User) {
        self.id = UUID(uuidString: firebaseUser.uid) ?? UUID()
        self.email = firebaseUser.email ?? ""
    }
}
