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
    @Environment(\.dismiss) var dismiss // Allows dismissing the sheet
    @EnvironmentObject var authService: AuthService
    @State private var username: String = ""
    @State private var errorMessage: String?
    @State private var isSubmitting: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Create a Username")
                    .font(.title2)
                    .bold()
                
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
                        await submitUsername()
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
    
    /// Validates username rules (at least 3 characters, no whitespace)
    private var isUsernameValid: Bool {
        return username.count >= 3 && !username.contains(" ")
    }
    
    /// Submits the username to Firestore under the current user's email as the document ID
    private func submitUsername() async {
        guard let userEmail = authService.currentUser?.email else {
            errorMessage = "User not logged in."
            return
        }
        
        let db = Firestore.firestore()
        let userDocRef = db.collection("users").document(userEmail)
        
        do {
            isSubmitting = true

            try await userDocRef.setData(["username": username], merge: true)
            authService.currentUser?.username = username
            dismiss()
        } catch {
            errorMessage = "Error saving username: \(error.localizedDescription)"
        }
        isSubmitting = false
    }
}

#Preview {
    CreateUsernameSheet()
}
