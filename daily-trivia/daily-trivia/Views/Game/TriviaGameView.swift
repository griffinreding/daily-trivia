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
    @State private var submittedAnswer: SubmittedAnswer?
    @State private var warnedAboutEmptyAnswer: Bool = false
    @State private var showUsernameEntry: Bool = false
    @State private var isShowingBugAlert: Bool = false
    @State private var isShowingLeaderboard: Bool = false
    
    lazy var functions = Functions.functions()
    
    var body: some View { // totally broken, asks me to answer teh question every login (maybe not actually broken?)
        NavigationView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Loading...")
                } else if let answer = submittedAnswer,
                          let question = question?.question,
                          let streak = authService.currentUser?.streak,
                          let username = authService.currentUser?.username {
                    if answer.answerOutcome {
                        CorrectAnswerView(submittedAnswer: answer,
                                          question: question,
                                          username: username,
                                          streak: streak)
                    } else {
                        if let correctAnswer = self.question?.correctAnswer {
                            IncorrectAnswerView(submittedAnswer: answer,
                                                correctAnswer: correctAnswer,
                                                username: username,
                                                question: question,
                                                streak: streak)
                        }
                    }
                } else if let question = question {
                    questionView(questionString: question.question)
                }
                else {
                    Text("No question available for today.")
                }

            }
            .padding()
            .onAppear {
                Task {
                    isLoading = true
                    if let answer = await GameService().checkResponseExists(for: Date().dateFormattedForDb(),
                                                                            email: authService.currentUser?.email) {
                        submittedAnswer = answer
                    }
                    await loadQuestion()
                    
                    showUsernameEntry = authService.currentUser?.username == nil
                    
                    isLoading = false
                }
            }
            .alert(isPresented: $isShowingAlert) {
                Alert(title: Text("Error"),
                      message: Text(errorMessage ?? "An error occurred."),
                      dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $isShowingBugAlert) {
                Alert(title: Text("Report a Bug"),
                      message: Text("If you find something dumb, it would be really cool if you let me know."),
                      primaryButton: .default(Text("Open Github"),
                                              action: {
                    guard let url = URL(string: "https://github.com/griffinreding/daily-trivia/issues/new") else {
                        errorMessage = "Lol, the bug report URL is broken. Nice."
                        isShowingAlert = true
                        return
                    }
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }), secondaryButton: .cancel())
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
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Leaderboard") {
                        isShowingLeaderboard = true
                    }
                }
                
                ToolbarItemGroup(placement: .bottomBar) {
                    Button {
                        isShowingBugAlert = true
                    } label: {
                        Image(systemName: "ladybug.fill")
                            .foregroundStyle(.red)
                    }
                    
                    Spacer()
                }
                
            }
            .sheet(isPresented: $showUsernameEntry) {
                CreateUsernameSheet()
                    .interactiveDismissDisabled()
            }
            .fullScreenCover(isPresented: $isShowingLeaderboard) {
                LeaderboardView(dismiss: {
                    isShowingLeaderboard = false
                })
            }
        }
    }
    
    func questionView(questionString: String) -> some View {
        VStack {
            if let username = authService.currentUser?.username, let streak = authService.currentUser?.streak {
                Text("Welcome back \(username)!")
                    .font(.headline)
                
                Text("Current Streak: \(streak) days.")
                    .font(.subheadline)
            }
            
            
            Text(questionString)
                .font(.title)
                .multilineTextAlignment(.center)
                .padding()
            
            TextField("Enter your answer", text: $answerText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button {
                Task {
                    if answerText.replacingOccurrences(of: " ", with: "").isEmpty {
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
            "username": authService.currentUser?.username ?? "Unknown",
            "date": question.date,
            "userAnswer": answerText,
            "answerOutcome": isCorrect,
            "question": question.question,
            "timestamp": FieldValue.serverTimestamp()
        ]
        
        do {
            try await db.collection("responses").document(userEmail).setData(responseData)
            try await authService.updateCurrentUsersStreak(streak: isCorrect ? (authService.currentUser?.streak ?? 0) + 1 : 0)
            
            submittedAnswer = SubmittedAnswer(date: question.date,
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
            .environmentObject(AuthService())
    }
}
