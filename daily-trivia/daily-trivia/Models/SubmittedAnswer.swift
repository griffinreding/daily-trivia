//
//  SubmittedAnswer.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import Foundation

struct SubmittedAnswer: Codable {
    let questionId: UUID
    let answerOutcome: Bool
}
