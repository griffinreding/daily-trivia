//
//  IncorrectAnswerView.swift
//  daily-trivia
//
//  Created by GReding on 2/21/25.
//

import SwiftUI

struct IncorrectAnswerView: View {
    let submittedAnswer: String
    let correctAnswer: String
    let username: String
    let question: String
    let streak: Int
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Tough break \(username).")
                .font(.headline)
            
            Image("sad")
                .resizable()
                .frame(width: 100, height: 100)
            
            Text("Your streak has been reset to \(streak) days.")
                .font(.footnote)
            
                
            Text("Your answer, \(submittedAnswer), was incorrect.")
            
            Text("The question was: \(question)")
            
            Text("The correct answer was: \(correctAnswer)")
            
            Text("Come back tomorrow to play again!")
        }
    }
}

#Preview {
    IncorrectAnswerView(submittedAnswer: "eleven", correctAnswer: "eleven", username: "GReding", question: "Huh?", streak: 11)
    
}
