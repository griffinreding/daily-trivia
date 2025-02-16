//
//  TriviaQuestion.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import Foundation
import FirebaseFirestoreSwift

struct Question: Codable, Identifiable {
    @DocumentID var id: String { date }
    let question: String
    let choices: [String]?
    let correctAnswer: String
    let date: String
}
