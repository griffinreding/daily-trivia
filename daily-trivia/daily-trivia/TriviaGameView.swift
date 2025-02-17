//
//  TriviaGameView.swift
//  daily-trivia
//
//  Created by GReding on 2/17/25.
//

import SwiftUI
import FirebaseFirestore

struct TriviaGameView: View {
    @State private var question: TriviaQuestion?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @State private var answerText: String = ""
    @State private var submitResult: String?
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Loading question...")
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else if let question = question {
                Text(question.question)
                    .font(.title)
                    .multilineTextAlignment(.center)
                    .padding()
                
                TextField("Enter your answer", text: $answerText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: {
                    Task {
                        await submitAnswer()
                    }
                }, label: {
                    Text("Submit Answer")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                })
                .padding(.horizontal)
                
                if let result = submitResult {
                    Text(result)
                        .font(.headline)
                        .foregroundColor(result == "Correct!" ? .green : .red)
                        .padding()
                }
            } else {
                Text("No question available for today.")
            }
        }
        .padding()
        .task {
            await loadQuestion()
        }
    }
    
    func loadQuestion() async {
        do {
            let formatter = DateFormatter()
            formatter.dateFormat = "M/d/yyyy"
            let today = formatter.string(from: Date())
            
            print("Date searched for \(today)")
            
            self.question = try await GameService.shared.fetchQuestion(for: today)
            
            isLoading = false
        }
        catch {
            
        }
    }
    
    // Call a cloud function to submit the answer instead of doing it locally
    func submitAnswer() async {
        guard let question = question else { return }
        let cleanedAnswer = answerText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let cleanedCorrect = question.correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if cleanedAnswer == cleanedCorrect {
            self.submitResult = "Correct!"
        } else {
            self.submitResult = "Wrong answer. Try again."
        }
    }
}

struct QuestionAnswerView_Previews: PreviewProvider {
    static var previews: some View {
        TriviaGameView()
    }
}
