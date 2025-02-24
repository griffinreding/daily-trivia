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
        VStack(alignment: .center, spacing: 12) {
            Text("Bingo!\nNice job \(authService.currentUser?.username ?? "(error)")!")
                .fixedSize()
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Image(systemName: "fireworks")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(.green)
            
            Text("Your streak is now \(authService.currentUser?.streak ?? 0) days🔥")
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
            
            Text("Come back tomorrow to play again!")
                .font(.title)
                .fontWeight(.bold)
                .lineLimit(nil)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.top, 36)
            
        }
    }
}

#Preview {
    CorrectAnswerView(submittedAnswer: SubmittedAnswer(date: "213456",
                                                       answerOutcome: true,
                                                       userAnswer: ";asdfasdf"),
                      question: TriviaQuestion(question: "I want to ask you a question and see if you can answer it. here it is: do you like me?",
                                               choices: nil,
                                               correctAnswer: "yeah",
                                               date: "234567"))
    .environmentObject(AuthService())
}
