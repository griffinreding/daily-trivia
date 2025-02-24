//
//  CorrectAnswerView.swift
//  daily-trivia
//
//  Created by GReding on 2/21/25.
//

import SwiftUI

struct CorrectAnswerView: View {
    @EnvironmentObject var authService: AuthService
    let submittedAnswer: SubmittedAnswer
    let question: TriviaQuestion
    
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Nailed it, \(authService.currentUser?.username ?? "username not found")!")
                .font(.headline)
            
            Image(systemName: "fireworks")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(.green)
            
            Text("Your streak is now \(authService.currentUser?.streak ?? 0) days🔥")
                .font(.footnote)

            Text("Your answer, \(submittedAnswer.userAnswer), was correct!")
            
            Text("The question was: \(question.question)")
            
            Text("Come back tomorrow to play again!")
                
        }
    }
}

#Preview {
    CorrectAnswerView(submittedAnswer: SubmittedAnswer(date: "213456",
                                                       answerOutcome: true,
                                                       userAnswer: ";asdfasdf"),
                      question: TriviaQuestion(question: "Huh",
                                               choices: nil,
                                               correctAnswer: "yeah",
                                               date: "234567"))
}
