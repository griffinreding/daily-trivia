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
    @StateObject var gameService = GameService()
    @State private var isLoading: Bool = true
    @State private var isShowingAlert: Bool = false
    @State private var errorMessage: String?
    @State private var answerText: String = ""
    @State private var resultMessage: String?
    @State private var warnedAboutEmptyAnswer: Bool = false
    @State private var showUsernameEntry: Bool = false
    @State private var isShowingBugAlert: Bool = false
    @State private var isShowingLeaderboard: Bool = false
    
    lazy var functions = Functions.functions()
    // totally broken, asks me to answer teh question every login (maybe not actually broken? nah still broken)
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                if isLoading {
                    ProgressView("Loading...")
                } else if let answer = gameService.submittedAnswer {
                    if answer.answerOutcome, let question = gameService.currentQuestion {
                        CorrectAnswerView(submittedAnswer: answer,
                                          question: question)
                    } else {
                        if let question = gameService.currentQuestion {
                            IncorrectAnswerView(submittedAnswer: answer,
                                                question: question)
                        }
                    }
                } else if let question = gameService.currentQuestion {
                    questionView(questionString: question.question)
                }
                else {
                    Text("No question available for today.")
                }
                
            }
            .padding()
            .onAppear {
                Task {
                    do {
                        isLoading = true
                        
                        await loadQuestion()
                        
                        //This is the wildest thing, the if statement below, has to be after loadQuestion() or it won't work
                        //It's like the environment object isn't available at the top of the block
                        //and gets initialized in the middle of this function.
                        //I've checked the load question function and it's not doing anything I could see that would cause this
                        
                        //try using .task instead
                        try await GameService().checkResponseExists(username: authService.currentUser?.username)
                        
                        showUsernameEntry = authService.currentUser?.username == nil
                        
                        isLoading = false
                    }
                    catch {
                        isLoading = false
                        errorMessage = error.localizedDescription
                        isShowingAlert = true
                    }
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
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .lineLimit(nil)
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                
                Text("Current Streak: \(streak) days.")
                    .font(.subheadline)
            }
            
            
            Text("Today's Question:")
                .font(.title)
                .fontWeight(.bold)
                .padding([.leading, .top])
            
            
            Text(questionString)
                .font(.title2)
                .lineLimit(nil)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            
            TextField("Enter your answer", text: $answerText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)
            
            Button {
                Task {
                    await submitAnswer()
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
            try await GameService().fetchTodaysQuestion()
        }
        catch {
            isLoading = false
            errorMessage = error.localizedDescription
            isShowingAlert = true
        }
    }
    
    func submitAnswer() async {
        if answerText.replacingOccurrences(of: " ", with: "").isEmpty, warnedAboutEmptyAnswer == false {
            errorMessage = "Do you really think the answer is blank? If you really want to try it I won't stop you, but this is the last warning you'll get."
            warnedAboutEmptyAnswer = true
            isShowingAlert = true
        } else {
            isLoading = true
            
            do {
                if let question = gameService.currentQuestion, let username = authService.currentUser?.username {
                    try await GameService().submitAnswer(question: question,
                                                         answerText: answerText,
                                                         username: username)
                    
                    if let outcome = gameService.submittedAnswer?.answerOutcome {
                        try await authService.updateCurrentUsersStreak(streak: outcome ?
                                                                       (authService.currentUser?.streak ?? 0) + 1 : 0)
                    }
                    
                    isLoading = false
                }
            }
            catch {
                isLoading = false
                errorMessage = error.localizedDescription
                isShowingAlert = true
            }
        }
    }
}

struct QuestionAnswerView_Previews: PreviewProvider {
    static var previews: some View {
        TriviaGameView()
            .environmentObject(AuthService())
    }
}
