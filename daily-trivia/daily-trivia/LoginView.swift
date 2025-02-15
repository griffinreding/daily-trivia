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
    @State private var showingAlert: Bool = false

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
                // Validate credentials
                if email.isEmpty || password.isEmpty {
                    showingAlert = true
                } else {
                    // Handle successful login here
                    print("Attempt login with \(email)")
                }
            }) {
                Text("Login")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            .alert(isPresented: $showingAlert) {
                Alert(title: Text("Missing Information"),
                      message: Text("Please enter your email and password."),
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
