//
//  TriviaQuestion.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import Foundation
//import FirebaseFirestoreSwift

struct TriviaQuestion: Codable, Identifiable {
    var id: String { date }
    let question: String
    let choices: [String]?
    let correctAnswer: String
    let date: String
}
