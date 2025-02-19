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
    @State private var answerAlreadyRecorded: Bool = false
    
    lazy var functions = Functions.functions()
    
    var body: some View {
        VStack(spacing: 20) {
            if isLoading {
                ProgressView("Loading question...")
            } else if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding()
            } else if answerAlreadyRecorded {
                Text("You have already submitted an answer for today.")
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
        .onAppear {
            Task {
                do {
                    try await AuthService.shared.signIn(email: "test@test.com", password: "test11") //For testing only
                    if await GameService.shared.checkResponseExists(for: Date().dateFormattedForDb()) {
                        answerAlreadyRecorded = true
                    }
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
    func submitAnswer() async {
        guard let question = question else { return }
        
        let userAnswerClean = answerText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let correctAnswerClean = question.correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let isCorrect = userAnswerClean == correctAnswerClean
        

        let db = Firestore.firestore()

        guard let userEmail = AuthService.shared.currentUser?.email else {
            print("User email not available")
            return
        }
        // Use the user's email as the document ID.
        let responseData: [String: Any] = [
            "userEmail": userEmail,
            "date": question.date,
            "userAnswer": answerText,
            "answerOutcome": isCorrect,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        do {
            try await db.collection("responses").document(userEmail).setData(responseData)
            print("Response recorded for user \(userEmail).")
        } catch {
            print("Error recording response: \(error.localizedDescription)")
        }
        
        // Provide feedback locally.
        if isCorrect {
            print("Correct Answer")
        } else {
            print("Wrong Answer")
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
