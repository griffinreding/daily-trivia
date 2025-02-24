//
//  ManualReview.swift
//  daily-trivia
//
//  Created by GReding on 2/22/25.
//

import Foundation

struct ManualReview: Codable {
    let username: String
    let date: String
    let question: String
    let correctAnswer: String
    let submittedAnswer: String
    let userNote: String
    let outcome: Bool
    let streak: Int
}
    
