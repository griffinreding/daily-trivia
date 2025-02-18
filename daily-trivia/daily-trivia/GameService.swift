//
//  GameService.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import Foundation
import FirebaseFirestore

class GameService {
    
    static let shared = GameService()
    
    func fetchTodaysQuestion() async throws -> TriviaQuestion? {
        let db = Firestore.firestore()
        // Here we use the date as the document ID
        //write code to get the current date from a Date() object as a string in the format "yyyy-MM-dd"
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
}

