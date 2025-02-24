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
        VStack(alignment: .center, spacing: 12) {
            Text("Tough break \(authService.currentUser?.username ?? "(error)").")
                .fixedSize()
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Image("sad")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(.red)
            
            Text("Your streak has been reset to \(authService.currentUser?.streak ?? 0) days.")
                .font(.subheadline)
                
            HStack {
                Text("Question:")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding([.leading, .top])
                Spacer()
            }
            
            Text(question.question)
                .font(.title2)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            HStack {
                Text("Your answer:")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading)
                
                Spacer()
            }
            
            Text(submittedAnswer.userAnswer)
                .font(.title2)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            HStack {
                Text("Correct answer:")
                    .font(.title)
                    .fontWeight(.bold)
                    .padding(.leading)
                
                Spacer()
            }
            
            Text(question.correctAnswer)
                .font(.title2)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            Button {
                isShowingManualReview = true
            } label: {
                Text("Submit for manual review")
            }
            
            Text("Come back tomorrow to play again!")
                .font(.subheadline)
                .fontWeight(.bold)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding([.top, .horizontal], 36)
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
    .environmentObject(AuthService())
    
}
