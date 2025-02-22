//
//  LeaderboardView.swift
//  daily-trivia
//
//  Created by GReding on 2/22/25.
//

import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var authService: AuthService
    @State private var leaderboard: [LeaderboardEntry] = []
    @State private var isLoading = true
    
    var body: some View {
        NavigationView {
            VStack {
                Text("🏆 Leaderboard 🏆")
                    .font(.largeTitle)
                    .padding()
                
                if isLoading {
                    ProgressView("Loading...")
                } else {
                    
                    HStack {
                        Text("Username")
                            .font(.headline)
                        
                        Spacer()
                        
                        Text("Correct Answers")
                            .font(.headline)
                    }
                    .background(Color.gray.opacity(0.2))
                    .padding()
                    
                    List(leaderboard, id: \.id) { entry in
                        HStack {
                            Text(entry.username)
                                .font(.headline)
                            Spacer()
                            Text("\(entry.numberOfCorrectAnswers) ✅")
                                .font(.subheadline)
                        }
                    }
                }
            }
            .task {
                await loadLeaderboard()
            }
        }
    }
    
    func loadLeaderboard() async {
        do {
            self.leaderboard = try await GameService().fetchLeaderboard()
            isLoading = false
        } catch {
            print("Failed to load leaderboard: \(error.localizedDescription)")
            isLoading = false
        }
    }
}
