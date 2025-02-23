//
//  IncorrectAnswerView.swift
//  daily-trivia
//
//  Created by GReding on 2/21/25.
//

import SwiftUI

struct IncorrectAnswerView: View {
    @State private var isShowingManualReview = false
    
    let submittedAnswer: SubmittedAnswer
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
            
                
            Text("Your answer, \(submittedAnswer.userAnswer), was incorrect.")
            
            Button {
                isShowingManualReview = true
            } label: {
                Text("Submit for manual review")
            }
            
            Text("The question was: \(question)")
            
            Text("The correct answer was: \(correctAnswer)")
            
            Text("Come back tomorrow to play again!")
        }
        .sheet(isPresented: $isShowingManualReview) {
            ManualReviewView(submittedAnswer: submittedAnswer,
                             correctAnswer: correctAnswer,
                             username: username,
                             question: question,
                             streak: streak,
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
                        correctAnswer: "eleven",
                        username: "GReding",
                        question: "Huh?",
                        streak: 11)
    
}
