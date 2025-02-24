//
//  IncorrectAnswerView.swift
//  daily-trivia
//
//  Created by GReding on 2/21/25.
//

import SwiftUI

struct IncorrectAnswerView: View {
    @EnvironmentObject var authService: AuthService
    @State private var isShowingManualReview = false
    
    let submittedAnswer: SubmittedAnswer
    let question: TriviaQuestion
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Tough break \(authService.currentUser?.username ?? "username not found").")
                .font(.headline)
            
            Image("sad")
                .resizable()
                .frame(width: 100, height: 100)
            
            Text("Your streak has been reset to \(authService.currentUser?.streak ?? 0) days.")
                .font(.footnote)
            
                
            Text("Your answer, \(submittedAnswer.userAnswer), was incorrect.")
            
            Button {
                isShowingManualReview = true
            } label: {
                Text("Submit for manual review")
            }
            
            Text("The question was: \(question.question)")
            
            Text("The correct answer was: \(question.correctAnswer)")
            
            Text("Come back tomorrow to play again!")
        }
        .sheet(isPresented: $isShowingManualReview) {
            ManualReviewView(submittedAnswer: submittedAnswer,
                             correctAnswer: question.correctAnswer,
                             username: authService.currentUser?.username ?? "unknown username",
                             question: question.question,
                             streak: authService.currentUser?.streak ?? 0,
                             dismiss: {
                isShowingManualReview = false
            })
        }
    }
}

#Preview {
    IncorrectAnswerView(submittedAnswer: SubmittedAnswer(date: "213456",
                                                         answerOutcome: true,
                                                         userAnswer: ";asdfasdf"),
                        question: TriviaQuestion(question: "Huh",
                                                 choices: nil,
                                                 correctAnswer: "yeah",
                                                 date: "234567"))
    
}
