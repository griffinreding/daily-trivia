//
//  LeaderboardView.swift
//  daily-trivia
//
//  Created by GReding on 2/22/25.
//

import SwiftUI

enum LeaderboardType: String, CaseIterable, Identifiable {
    case mostCorrect = "Most Correct"
    case longestStreak = "Longest Streak"

    var id: String { self.rawValue }
    
    var columnHeaderText: String {
        switch self {
        case .mostCorrect:
            return "Correct Answers"
        case .longestStreak:
            return "Longest Streak"
        }
    }
}

struct LeaderboardView: View {
    @EnvironmentObject var authService: AuthService
    @State private var correctAnswerLeaderboard: [LeaderboardEntry] = []
    @State private var streakLeaderboard: [LeaderboardEntry] = []
    @State private var isLoading = true
    @State private var selectedLeaderboard = LeaderboardType.mostCorrect
    
    var dismiss: (() -> Void)
    
    var body: some View {
        NavigationView {
            VStack {
                Text("🏆 Leaderboard 🏆")
                    .font(.largeTitle)
                    .padding()
                
                if isLoading {
                    ProgressView("Loading...")
                } else {
                    
                    Picker("Leaderboard Type", selection: $selectedLeaderboard) {
                        ForEach(LeaderboardType.allCases) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding()
                    
                    HStack {
                        Text("Username")
                            .font(.headline)
                            .padding(.leading, 8)
                        
                        Spacer()
                        
                        Text(selectedLeaderboard.columnHeaderText)
                            .font(.headline)
                            .padding(.trailing, 8)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    
                    
                    switch self.selectedLeaderboard {
                    case .mostCorrect:
                        totalCorrectAnswersLeaderboard()
                    case .longestStreak:
                        longestStreakLeaderboard()
                    }
                }
                
                Spacer()
            }
            .task {
                await loadCorrectAnswersLeaderboard()
                await loadStreakLeaderboard()
                isLoading = false
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close Leaderboard") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    func loadCorrectAnswersLeaderboard() async {
        do {
            self.correctAnswerLeaderboard = try await GameService().fetchCorrectAnswersLeaderboard()
        } catch {
            print("Failed to load leaderboard: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    func loadStreakLeaderboard() async {
        do {
            self.streakLeaderboard = try await GameService().fetchStreakLeaderboard()
        } catch {
            print("Failed to load leaderboard: \(error.localizedDescription)")
            isLoading = false
        }
    }
    
    func totalCorrectAnswersLeaderboard() -> some View {
        List(correctAnswerLeaderboard, id: \.id) { entry in
            HStack {
                Text(entry.username)
                    .font(.headline)
                Spacer()
                Text("\(entry.value) ✅")
                    .font(.subheadline)
            }
        }
    }
    
    func longestStreakLeaderboard() -> some View {
        List(streakLeaderboard, id: \.id) { entry in
            HStack {
                Text(entry.username)
                    .font(.headline)
                Spacer()
                Text("\(entry.value) 🔥")
                    .font(.subheadline)
            }
        }
    }
}
