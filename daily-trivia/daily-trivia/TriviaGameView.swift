//
//  TriviaGameView.swift
//  daily-trivia
//
//  Created by GReding on 2/17/25.
//

import SwiftUI
import Firebase
import FirebaseFirestore

struct TriviaGameView: View {
    @State private var question: TriviaQuestion?
    @State private var isLoading: Bool = true
    @State private var errorMessage: String?
    @State private var answerText: String = ""
    @State private var submitResult: String?
    
    lazy var functions = Functions.functions()
    
    let cloudFunctionURL = "https://<us-central1>-<your-project-id>.cloudfunctions.net/submitAnswer"
    
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
            self.question = try await GameService.shared.fetchTodaysQuestion()
            
            isLoading = false
        }
        catch {
            
        }
    }
    
    func submitAnswer() async {
            guard let question = question else { return }
            
            // Create the request payload.
            let payload: [String: Any] = [
                "userId": "testUserID", // Replace with the actual authenticated user's ID.
                "userAnswer": answerText,
                "date": question.date // Ensure this matches the Firestore document ID.
            ]
            
            guard let url = URL(string: cloudFunctionURL) else {
                resultMessage = "Invalid function URL."
                return
            }
            
            do {
                // Create and configure the URLRequest.
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.addValue("application/json", forHTTPHeaderField: "Content-Type")
                request.httpBody = try JSONSerialization.data(withJSONObject: payload)
                
                // Perform the network request.
                let (data, _) = try await URLSession.shared.data(for: request)
                // Decode the response.
                if let jsonResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let correct = jsonResponse["correct"] as? Bool {
                    
                    if correct {
                        resultMessage = "Correct!"
                    } else {
                        if let correctAnswer = jsonResponse["correctAnswer"] as? String {
                            resultMessage = "Wrong answer. The correct answer is: \(correctAnswer)"
                        } else {
                            resultMessage = "Wrong answer."
                        }
                    }
                } else {
                    resultMessage = "Unexpected response from server."
                }
            } catch {
                resultMessage = "Submission failed: \(error.localizedDescription)"
            }
        }
}

struct QuestionAnswerView_Previews: PreviewProvider {
    static var previews: some View {
        TriviaGameView()
    }
}
