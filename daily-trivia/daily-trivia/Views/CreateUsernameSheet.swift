//
//  CreateUsernameSheet.swift
//  daily-trivia
//
//  Created by GReding on 2/21/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct CreateUsernameSheet: View {
    @EnvironmentObject var authService: AuthService
    @Environment(\.dismiss) var dismiss
    @State private var username: String = ""
    @State private var errorMessage: String?
    @State private var isSubmitting: Bool = false
    
    var body: some View {
        NavigationView {
            VStack {
                VStack(alignment: .center, spacing: 20) {
                    Text("Welcome to Daily Trivia!")
                        .font(.title2)
                        .bold()
                    
                    Text("Create a username to get started.")
                        .font(.headline)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Your username will be visible to other players on the leaderboard, and must meet the following requirements:")
                        .font(.subheadline)
                    
                    Text("- At least 3 characters long, no longer than 24.")
                        .font(.subheadline)
                    
                    Text("- No spaces")
                        .font(.subheadline)
                    
                    TextField("Enter username", text: $username)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    
                    if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.horizontal)
                    }
                    
                    Button(action: {
                        Task {
                            do {
                                isSubmitting = true
                                try await authService.submitUsername(username: username)
                                dismiss()
                            }
                            catch {
                                errorMessage = error.localizedDescription
                            }
                        }
                    }) {
                        Text("Submit")
                            .bold()
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isUsernameValid ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(!isUsernameValid || isSubmitting)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
            }
        }
    }
    
    /// Validates username rules (at least 3 characters, no whitespace)
    private var isUsernameValid: Bool {
        return username.count >= 3 &&
        username.count <= 24 &&
        !username.contains(" ")
    }
    
}

#Preview {
    CreateUsernameSheet()
}
