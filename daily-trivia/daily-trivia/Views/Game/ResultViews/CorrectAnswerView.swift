//
//  CorrectAnswerView.swift
//  daily-trivia
//
//  Created by GReding on 2/21/25.
//

import SwiftUI

struct CorrectAnswerView: View {
    let submittedAnswer: String
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "fireworks")
                .resizable()
                .frame(width: 100, height: 100)
            
            Text("Nailed it!")
                
            Text("Your answer, \(submittedAnswer), was correct!")
            
            Text("Come back tomorrow to play again!")
                
        }
    }
}

#Preview {
    CorrectAnswerView(submittedAnswer: "Hippopotamus")
}
