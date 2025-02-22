//
//  IncorrectAnswerView.swift
//  daily-trivia
//
//  Created by GReding on 2/21/25.
//

import SwiftUI

struct IncorrectAnswerView: View {
    let submittedAnswer: String
    
    var body: some View {
        VStack(spacing: 24) {
            Image("sad")
                .resizable()
                .frame(width: 100, height: 100)
                .foregroundStyle(.green)
            
            Text("Bummer!")
                
            Text("Your answer, \(submittedAnswer), was incorrect.")
            
            Text("Come back tomorrow to play again!")
        }
    }
}

#Preview {
    IncorrectAnswerView(submittedAnswer: "eleven")
}
