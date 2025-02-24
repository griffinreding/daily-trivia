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
    var leaderboard: [LeaderboardEntry] = []
    
    //clean up queries using these docs when i'm done being lazy
    //https://firebase.google.com/docs/firestore/query-data/queries?hl=en&authuser=1
    
    func fetchTodaysQuestion() async throws -> TriviaQuestion? {
        let db = Firestore.firestore()

        let docRef = db.collection("questions").document(Date().dateFormattedForDb())
        
        let snapshot = try await docRef.getDocumentAsync()
        if snapshot.exists {
            print("Question snapshot exists!")
            return try snapshot.data(as: TriviaQuestion.self)
        } else {
            print("Question snapshot does not exist.")
            return nil
        }
    }
    
    func checkResponseExists(for datefordb: String, username: String?) async -> SubmittedAnswer? {
        guard let username = username else {
            print("Username not available")
            return nil
        }
        
        let db = Firestore.firestore()
        
        do {
            let querySnapshot = try await db.collection("responses")
                .whereField("username", isEqualTo: username)
                .getDocuments()

            for document in querySnapshot.documents {
                if let answerDate = document.data()["date"] as? String, datefordb == answerDate {
                    print("Response found for \(username) on \(datefordb)")
                    return try document.data(as: SubmittedAnswer.self)
                }
            }
            
            print("No response found for \(username) on \(datefordb)")
            return nil
        } catch {
            print("Error fetching responses: \(error.localizedDescription)")
            return nil
        }
    }
    
    func submitAnswer(question: TriviaQuestion, answerText: String, username: String) async throws -> SubmittedAnswer {
        let userAnswerClean = answerText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let correctAnswerClean = question.correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let isCorrect = userAnswerClean == correctAnswerClean
        
        
        let db = Firestore.firestore()
        
        let responseData: [String: Any] = [
            "username": username,
            "date": question.date,
            "userAnswer": answerText,
            "answerOutcome": isCorrect,
            "question": question.question,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        try await db.collection("responses").document(username).setData(responseData)
        
        return SubmittedAnswer(date: question.date,
                               answerOutcome: isCorrect,
                               userAnswer: answerText)
    }
    
    func fetchCorrectAnswersLeaderboard() async throws -> [LeaderboardEntry] {
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
        
        let sortedLeaderboard = leaderboard.map { LeaderboardEntry(username: $0.key, value: $0.value) }
            .sorted { $0.value > $1.value }
//            .prefix(20)
        
        return Array(sortedLeaderboard)
    }
    
    func fetchStreakLeaderboard() async throws -> [LeaderboardEntry] {
        let db = Firestore.firestore()
        var leaderboard: [String: Int] = [:]
        
        let snapshot = try await db.collection("streaks")
            .getDocuments()
        
        for document in snapshot.documents {
            let data = document.data()
            let username = data["username"] as? String ?? "Unknown"
            let streak = data["streak"] as? Int ?? 0
            
            leaderboard[username, default: 0] += streak
        }
        
        let sortedLeaderboard = leaderboard.map { LeaderboardEntry(username: $0.key, value: $0.value) }
            .sorted { $0.value > $1.value }
        
        return Array(sortedLeaderboard)
    }
    
    func submitAnswerForManualReview(submittedAnswer: SubmittedAnswer,
                                     username: String,
                                     question: String,
                                     correctAnswer: String,
                                     userNote: String,
                                     streak: Int,
                                     outcome: Bool) async throws -> Bool {
        
        let db = Firestore.firestore()
        let reviewsRef = db.collection("manualReviews").document(username)
        
        let snapshot = try await db.collection("manualReviews")
            .whereField("username", isEqualTo: username)
            .getDocuments()
        
        
        for document in snapshot.documents {
            let manualReview = try document.data(as: ManualReview.self)
            
            if manualReview.date == Date().dateFormattedForDb() {
                return false
            }
        }
        
        
        let manualReview: [String: Any] = [
            "username": username,
            "date": Date().dateFormattedForDb(),
            "question": question,
            "correctAnswer": correctAnswer,
            "submittedAnswer": submittedAnswer.userAnswer,
            "outcome": outcome,
            "userNote": userNote,
            "streak": streak
        ]
        
        try await reviewsRef.setDataAsync(manualReview)
        print("Manual review submitted")
        
        return true
    }
    


}

