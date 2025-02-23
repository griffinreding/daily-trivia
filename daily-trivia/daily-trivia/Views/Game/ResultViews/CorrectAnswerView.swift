//
//  CorrectAnswerView.swift
//  daily-trivia
//
//  Created by GReding on 2/21/25.
//

import SwiftUI

struct CorrectAnswerView: View {
    let submittedAnswer: String
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

            Text("Your answer, \(submittedAnswer), was correct!")
            
            Text("The question was: \(question)")
            
            Text("Come back tomorrow to play again!")
                
        }
    }
}

#Preview {
    CorrectAnswerView(submittedAnswer: "1234",
                      question: "Huh?",
                      username: "gobblegobble",
                      streak: 3)
}
