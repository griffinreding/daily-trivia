//
//  LoginView.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import SwiftUI
import GoogleSignInSwift
import GoogleSignIn

enum LoginViewAlert: Identifiable {
        case missingInput
        case loginError(String)
        case registrationPrompt
        
        var id: String {
            switch self {
            case .missingInput: return "missingInput"
            case .loginError: return "loginError"
            case .registrationPrompt: return "registrationPrompt"
            }
        }
    }

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var loginViewAlert: LoginViewAlert? = nil

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to Daily Trivia!")
                .fixedSize()
                .font(.largeTitle)
                .fontWeight(.bold)
                .lineLimit(0)
                .multilineTextAlignment(.center)
            
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
                GoogleSignInButton(action: handleSignInButton)
            }
            
            Button {
                if email.isEmpty || password.isEmpty {
                    loginViewAlert = .missingInput
                } else {
                    Task {
                        do {
                            let user = try await authService.signIn(email: email,
                                                                           password: password)
                            
                            try await authService.fetchUsername(forEmail: user.email ?? "")
                            try await authService.fetchUserStreak(forUsername: authService.currentUser?.username ?? "")
                        } catch {
                            loginViewAlert = .loginError(error.localizedDescription)
                            print("Login error: \(error.localizedDescription)")
                        }
                    }
                }
            } label: {
                Text("Login")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(8)
            }
            
            Button {
                if email.isEmpty || password.isEmpty {
                    loginViewAlert = .registrationPrompt
                } else {
                    Task {
                        do {
                            try await authService.signUp(email: email, password: password)
                            
                            let user = try await authService.signIn(email: email, password: password)
                            try await authService.createUserAccountIfNeeded(for: user)
                            try await authService.fetchUserStreak(forUsername: authService.currentUser?.username ?? "")
                        } catch {
                            loginViewAlert = .loginError(error.localizedDescription)
                            print("Registration error: \(error.localizedDescription)")
                        }
                    }
                }
            } label: {
                Text("Register")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green)
                    .cornerRadius(8)
            }
            
            Spacer()
        }
        .padding()
        .alert(item: $loginViewAlert) { alert in
            switch alert {
            case .missingInput:
                return Alert(title: Text("Missing Information"),
                             message: Text("Please enter your email and password."),
                             dismissButton: .default(Text("OK")))
                
            case .loginError(let message):
                return Alert(title: Text("Login Error"),
                             message: Text(message),
                             dismissButton: .default(Text("OK")))
                
            case .registrationPrompt:
                return Alert(title: Text("Registration"),
                             message: Text("Enter an email and password above, then tap 'Register' to create an account."),
                             dismissButton: .default(Text("OK")))
            }
        }
        
    }
    
    func handleSignInButton() {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                Task {
                    do {
                        guard let result = signInResult else {
                            loginViewAlert = .loginError("Error signing in with Google: \(error?.localizedDescription ?? "Unknown error")")
                            return
                        }
                        
                        guard let email = result.user.profile?.email else {
                            loginViewAlert = .loginError("Unable to get email from Google sign in. Please ensure your sharing settings allow it.")
                            return
                        }
                        
                        let user = result.user
                        try await authService.createUserAccountFromGoogleIfNeeded(for: user)
                        authService.currentUser = User(googleUser: user)
                        
                        try await authService.fetchUsername(forEmail: email)
                        try await authService.fetchUserStreak(forUsername: authService.currentUser?.username ?? "")
                    }
                    catch {
                        loginViewAlert = .loginError("Error creating firebase account after google sign in: \(error.localizedDescription)")
                    }
                }
            }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
