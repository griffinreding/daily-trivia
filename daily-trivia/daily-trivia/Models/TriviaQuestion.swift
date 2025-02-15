//
//  TriviaQuestion.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import Foundation

struct TriviaQuestion: Codable {
    let question: String
    let answer: String
    let id: UUID
}
