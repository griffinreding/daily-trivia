//
//  GameService.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import Foundation
import FirebaseFirestore
import SwiftUI

class GameService {
    
    //clean up cloud functions using these docs
    //https://firebase.google.com/docs/firestore/query-data/queries?hl=en&authuser=1
    
    func fetchTodaysQuestion() async throws -> TriviaQuestion? {
        let db = Firestore.firestore()

        let currentDate = Date().dateFormattedForDb()
        
        print("documentId searched for: \(currentDate)")
        
        let docRef = db.collection("questions").document(currentDate)
        
        let snapshot = try await docRef.getDocumentAsync()
        if snapshot.exists {
            print("Question snapshot exists!")
            return try snapshot.data(as: TriviaQuestion.self)
        } else {
            print("Question snapshot does not exist.")
            return nil
        }
    }
    
    func checkResponseExists(for datefordb: String, email: String?) async -> Bool {
        // Get the current user's email from Firebase Auth.
        guard let userEmail = email else {
            print("User email not available")
            return false
        }
        
        let db = Firestore.firestore()
        
        do {
            let querySnapshot = try await db.collection("responses")
                .whereField("userEmail", isEqualTo: userEmail)
                .getDocuments()

            for document in querySnapshot.documents {
                if let answerDate = document.data()["date"] as? String {
                    return datefordb == answerDate
                }
            }
        } catch {
            print("Error fetching responses: \(error.localizedDescription)")
            return false
        }
        
        return false
    }
}

