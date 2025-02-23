//
//  CorrectAnswerView.swift
//  daily-trivia
//
//  Created by GReding on 2/21/25.
//

import SwiftUI

struct CorrectAnswerView: View {
    let submittedAnswer: SubmittedAnswer
    let question: String
    let username: String
    let streak: Int
    
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Nailed it, \(username)!")
                .font(.headline)
            
            Image(systemName: "fireworks")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(.green)
            
            Text("Your streak is now \(streak) days🔥")
                .font(.footnote)

            Text("Your answer, \(submittedAnswer.userAnswer), was correct!")
            
            Text("The question was: \(question)")
            
            Text("Come back tomorrow to play again!")
                
        }
    }
}

#Preview {
    CorrectAnswerView(submittedAnswer: SubmittedAnswer(date: "213456",
                                                       answerOutcome: true,
                                                       userAnswer: ";asdfasdf"),
                      question: "Huh?",
                      username: "gobblegobble",
                      streak: 3)
}
