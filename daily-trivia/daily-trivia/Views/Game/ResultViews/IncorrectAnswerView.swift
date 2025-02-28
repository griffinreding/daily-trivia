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
        VStack(alignment: .center, spacing: 0) {
            Text("Tough break \(authService.currentUser?.username ?? "(error)").")
                .font(.largeTitle)
                .fontWeight(.bold)
                .fixedSize(horizontal: false, vertical: true)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
                .padding(.bottom, 12)
            
            Image("sad")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(.red)
                .padding(.bottom, 24)
            
            Text("Your streak has been reset to \(authService.currentUser?.streak ?? 0) days.")
                .font(.subheadline)
            
            VStack(spacing: 0) {
                HStack {
                    Text("Today's Question:")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding([.leading, .top])
                    Spacer()
                }
                
                Text(question.question)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                HStack {
                    Text("Your answer:")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding(.leading)
                    
                    Spacer()
                }
                
                Text(submittedAnswer.userAnswer)
                    .font(.body)
                    .fixedSize(horizontal: false, vertical: true)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                
                HStack {
                    Text("Correct answer:")
                        .font(.subheadline)
                        .fontWeight(.bold)
                        .padding(.leading)
                    
                    Spacer()
                }
                
                Text(question.correctAnswer)
                    .font(.body)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
            }
                
            Button {
                isShowingManualReview = true
            } label: {
                Text("Submit for manual review")
            }
            
            Text("Come back tomorrow to play again!")
                .font(.subheadline)
                .fontWeight(.bold)
                .fixedSize(horizontal: false, vertical: true)
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
