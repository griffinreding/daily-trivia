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
    
    //clean up queries using these docs when i'm done being lazy
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
    
    func checkResponseExists(for datefordb: String, email: String?) async -> SubmittedAnswer? {
        guard let userEmail = email else {
            print("User email not available")
            return nil
        }
        
        let db = Firestore.firestore()
        
        do {
            let querySnapshot = try await db.collection("responses")
                .whereField("userEmail", isEqualTo: userEmail)
                .getDocuments()

            for document in querySnapshot.documents {
                if let answerDate = document.data()["date"] as? String, datefordb == answerDate {
                    return try document.data(as: SubmittedAnswer.self)
                }
            }
            
            return nil
        } catch {
            print("Error fetching responses: \(error.localizedDescription)")
            return nil
        }
    }
    
    func fetchLeaderboard() async throws -> [LeaderboardEntry] {
        let db = Firestore.firestore()
        var leaderboard: [String: Int] = [:]
        
        let snapshot = try await db.collection("responses")
            .whereField("answerOutcome", isEqualTo: true)
            .getDocuments()
        
        for document in snapshot.documents {
            let data = document.data()
            let username = data["username"] as? String ?? "Unknown"
            
            leaderboard[username, default: 0] += 1
        }
        
        let sortedLeaderboard = leaderboard.map { LeaderboardEntry(username: $0.key, numberOfCorrectAnswers: $0.value) }
            .sorted { $0.numberOfCorrectAnswers > $1.numberOfCorrectAnswers }
            .prefix(20)
        
        return Array(sortedLeaderboard)
    }
    
}

