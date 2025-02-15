//
//  LoginView.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var isShowingMissingInputAlert: Bool = false
    @State private var isShowingLogInAlert: Bool = false
    @State var alertErrorMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Daily Trivia!")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            TextField("Email", text: $email)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            SecureField("Password", text: $password)
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(8)
            
            HStack {
                
            }
            
            Button(action: {
                if email.isEmpty || password.isEmpty {
                    isShowingMissingInputAlert = true
                } else {
                    Task {
                        do {
                            let user = try await AuthService.shared.signIn(email: email,
                                                                           password: password)
                            // Update UI for successful login.
                            print("Logged in as: \(user.id)")
                        } catch {
                            alertErrorMessage = error.localizedDescription
                            isShowingLogInAlert = true
                            print("Login error: \(error.localizedDescription)")
                        }
                    }
                }
            }) {
                Text("Login")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .alert(isPresented: $isShowingMissingInputAlert) {
                Alert(title: Text("Missing Information"),
                      message: Text("Please enter your email and password."),
                      dismissButton: .default(Text("OK")))
            }
            .alert(isPresented: $isShowingLogInAlert) {
                Alert(title: Text("Login Error"),
                      message: Text(alertErrorMessage),
                      dismissButton: .default(Text("OK")))
            }
            
            Spacer()
        }
        .padding()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
