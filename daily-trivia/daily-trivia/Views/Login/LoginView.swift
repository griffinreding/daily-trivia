//
//  LoginView.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import SwiftUI
import GoogleSignInSwift
import GoogleSignIn

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
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
                GoogleSignInButton(action: handleSignInButton)
            }
            
            Button {
                if email.isEmpty || password.isEmpty {
                    isShowingMissingInputAlert = true
                } else {
                    Task {
                        do {
                            let user = try await AuthService().signIn(email: email,
                                                                           password: password)
                            
                            print("Logged in as: \(user.id)")
                        } catch {
                            alertErrorMessage = error.localizedDescription
                            isShowingLogInAlert = true
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
    
    func handleSignInButton() {
            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
            guard let rootViewController = windowScene.windows.first?.rootViewController else { return }
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                Task {
                    do {
                        guard let result = signInResult else {
                            alertErrorMessage = "Error signing in with Google: \(error?.localizedDescription ?? "Unknown error")"
                            isShowingLogInAlert = true
                            return
                        }
                        
                        guard result.user.profile?.email != nil else {
                            alertErrorMessage = "Unable to get email from Google sign in. Please ensure your sharing settings allow it."
                            isShowingLogInAlert = true
                            return
                        }
                        
                        let user = result.user
                        try await AuthService().createUserAccountFromGoogleIfNeeded(for: user)
                        authService.currentUser = User(googleUser: user)
                    }
                    catch {
                        self.alertErrorMessage = "Error creating firebase account after google sign in: \(error.localizedDescription)"
                        self.isShowingLogInAlert = true
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
