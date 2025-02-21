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
    @EnvironmentObject var authService: AuthService
    @State private var question: TriviaQuestion?
    @State private var isLoading: Bool = true
    @State private var isShowingAlert: Bool = false
    @State private var errorMessage: String?
    @State private var answerText: String = ""
    @State private var submitResult: String?
    @State private var resultMessage: String?
    @State private var previouslySubmittedAnswer: SubmittedAnswer?
    @State private var warnedAboutEmptyAnswer: Bool = false
    
    lazy var functions = Functions.functions()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Loading...")
                } else if let answer = previouslySubmittedAnswer {
                    if answer.answerOutcome {
                        CorrectAnswerView(submittedAnswer: answer.userAnswer)
                    } else {
                        
                    }
//                    Text("You have already submitted an answer for today.")
//                    Text("Your answer of \(answer.userAnswer), was \(answer.answerOutcome ? "correct!" : "incorrect.")")
                } else if let question = question {
                    Text(question.question)
                        .font(.title)
                        .multilineTextAlignment(.center)
                        .padding()
                    
                    TextField("Enter your answer", text: $answerText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Button {
                        Task {
                            if answerText.isEmpty {
                                errorMessage = "Do you really think the answer is blank? If you really want to try it I won't stop you, but this is the last warning you'll get."
                                warnedAboutEmptyAnswer = true
                                isShowingAlert = true
                            } else {
                                isLoading = true
                                await submitAnswer()
                                isLoading = false
                            }
                        }
                    } label: {
                        Text("Submit Answer")
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
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
                    isLoading = true
                    if let answer = await GameService().checkResponseExists(for: Date().dateFormattedForDb(),
                                                                            email: authService.currentUser?.email) {
                        previouslySubmittedAnswer = answer
                        isLoading = false
                    }
                    await loadQuestion()
                }
            }
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text("Error"),
                      message: Text(errorMessage ?? "An error occurred."),
                      dismissButton: .default(Text("OK")))
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Logout") {
                        Task {
                            do {
                                isLoading = true
                                try authService.logout()
                                isLoading = false
                            }
                            catch {
                                isLoading = false
                                errorMessage = "Error logging out: \(error.localizedDescription)"
                                isShowingAlert = true
                            }
                        }
                    }
                }
            }
        }
    }
    
    func loadQuestion() async {
        do {
            self.question = try await GameService().fetchTodaysQuestion()
            isLoading = false
        }
        catch {
            isLoading = false
            errorMessage = error.localizedDescription
            isShowingAlert = true
        }
    }
    func submitAnswer() async {
        guard let question = question else { return }
        
        let userAnswerClean = answerText.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let correctAnswerClean = question.correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let isCorrect = userAnswerClean == correctAnswerClean
        

        let db = Firestore.firestore()

        guard let userEmail = authService.currentUser?.email else {
            errorMessage = "User email not available. Please log back in again and try again."
            isShowingAlert = true
            return
        }

        let responseData: [String: Any] = [
            "userEmail": userEmail,
            "date": question.date,
            "userAnswer": answerText,
            "answerOutcome": isCorrect,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        do {
            try await db.collection("responses").document(userEmail).setData(responseData)
            
            previouslySubmittedAnswer = SubmittedAnswer(date: question.date,
                                                        answerOutcome: isCorrect,
                                                        userAnswer: answerText)
                                                        
            
            print("Response recorded for user \(userEmail).")
        } catch {
            isLoading = false
            errorMessage = "Error saving response: \(error.localizedDescription)"
            isShowingAlert = true
            return
        }
        

        if isCorrect {
            print("Correct Answer")
        } else {
            print("Wrong Answer")
        }
    }
}

struct QuestionAnswerView_Previews: PreviewProvider {
    static var previews: some View {
        TriviaGameView()
    }
}
