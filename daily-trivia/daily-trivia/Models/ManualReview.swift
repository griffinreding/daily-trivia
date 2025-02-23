//
//  ManualReview.swift
//  daily-trivia
//
//  Created by GReding on 2/22/25.
//

import Foundation

struct ManualReview: Codable {
    let date: String
    let question: String
    let correctAnswer: String
    let userAnswer: String
    let userNote: String
    let username: String
}
    
