//
//  HistoricalResponsesService.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import Foundation
import FirebaseFirestore

class HistoricalResponsesService {
    
//    func fetchUserHistory(userId: String, completion: @escaping ([HistoricalResponse]) -> Void) {
//        let db = Firestore.firestore()
//        db.collection("responses")
//          .whereField("userId", isEqualTo: userId)
//          .order(by: "date", descending: true)
//          .getDocuments { snapshot, error in
//              if let error = error {
//                  print("Error fetching history: \(error)")
//                  completion([])
//                  return
//              }
//              guard let documents = snapshot?.documents else {
//                  completion([])
//                  return
//              }
//              let responses = documents.compactMap { doc -> HistoricalResponse? in
//                  return try? doc.data(as: HistoricalResponse.self)
//              }
//              completion(responses)
//          }
//    }
    
}
