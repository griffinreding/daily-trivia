//
//  HistoricalResponse.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import Foundation

struct HistoricalResponse: Codable {
    let userId: UUID
    let date: Date
    let question: String
    let userAnswer: String
    let correctAnswer: String
    let correct: Bool
}
