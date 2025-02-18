//
//  TriviaGameView.swift
//  daily-trivia
//
//  Created by GReding on 2/17/25.
//

import SwiftUI
import FirebaseFunctions
import FirebaseFirestore


struct TriviaGameView: View {
    @State private var question: TriviaQuestion?
    @State private var isLoading: Bool = true
    @State private var isShowingAlert: Bool = false
    @State private var errorMessage: String?
    @State private var answerText: String = ""
    @State private var submitResult: String?
    @State private var resultMessage: String?
    
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
//                        if let user = AuthService.shared.currentUser {
                            //need to figure out what to do with the result dictionary
                            await submitAnswer(userId: "test@test.com", userAnswer: answerText, date: question.date)
//                        }
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
        .onAppear {
            Task {
                do {
                    try await AuthService.shared.signIn(email: "test@test.com", password: "test11")
                    await loadQuestion()
                }
                catch {
                    print("")
                }
            }
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text("Error"),
                  message: Text(errorMessage ?? "An error occurred."),
                  dismissButton: .default(Text("OK")))
        }
//        .task {
//            await loadQuestion()
//        }
    }
    
    func loadQuestion() async {
        do {
            self.question = try await GameService.shared.fetchTodaysQuestion()
            print(self.question)
            isLoading = false
        }
        catch {
            
        }
    }
    
    func submitAnswer(userId: String, userAnswer: String, date: String) async /*-> Result<[String: Any], Error>*/ {
        let functions = Functions.functions()
        let data = ["userId": userId, "userAnswer": userAnswer, "date": date]
        
        do {
            // Call the Cloud Function "submitAnswer"
            let result = try await functions.httpsCallable("submitAnswer").call(data)
            
            // Process the response
            if let data = result.data as? [String: Any],
               let correct = data["correct"] as? Bool {
                if correct {
                    errorMessage = "Correct!"
                    isShowingAlert = true
                } else if let correctAnswer = data["correctAnswer"] as? String {
                    errorMessage = "Wrong answer. The correct answer is: \(correctAnswer)"
                    isShowingAlert = true
                } else {
                    errorMessage = "Wrong answer."
                    isShowingAlert = true
                }
            } else {
                errorMessage = "Unexpected response from server."
                isShowingAlert = true
            }
        } catch let error as NSError {
            // Check if this error comes from Firebase Functions
            if error.domain == FunctionsErrorDomain {
                // Retrieve a functions-specific error code and details
                let errorCode = FunctionsErrorCode(rawValue: error.code)
                let errorDetails = error.userInfo[FunctionsErrorDetailsKey] ?? "No additional details."
                errorMessage = "Error (\(errorCode?.rawValue ?? error.code)): \(error.localizedDescription)\nDetails: \(errorDetails)"
                isShowingAlert = true
            } else {
                errorMessage = "Submission failed: \(error.localizedDescription)"
            }
        }
    }
        
        
        
        
        
//        return await withCheckedContinuation { continuation in
//            functions.httpsCallable("submitAnswer").call(data) { result, error in
//                if let data = result?.data as? [String: Any],
//                   let correct = data["correct"] as? Bool {
//                    if correct {
//                        resultMessage = "Correct!"
//                    } else if let correctAnswer = data["correctAnswer"] as? String {
//                        resultMessage = "Wrong answer. The correct answer is: \(correctAnswer)"
//                    } else {
//                        resultMessage = "Wrong answer."
//                    }
//                } else {
//                    resultMessage = "Unexpected response from server."
//                }
//            }
//        }
}

struct QuestionAnswerView_Previews: PreviewProvider {
    static var previews: some View {
        TriviaGameView()
    }
}
