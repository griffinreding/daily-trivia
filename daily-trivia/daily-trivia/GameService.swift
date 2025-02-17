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
    
    func fetchQuestion(for date: String) async throws -> TriviaQuestion? {
        let db = Firestore.firestore()
        // Here we use the date as the document ID
        let docRef = db.collection("questions").document(date)
        
//        let asdf = try await db.collection("questions").whereField("id", isEqualTo: date).getDocuments()
//        
//        print(asdf)
        
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

