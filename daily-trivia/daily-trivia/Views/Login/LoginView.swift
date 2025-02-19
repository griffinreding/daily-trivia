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
    @EnvironmentObject private var appState: AppState
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
                            let user = try await AuthService(appState: appState).signIn(email: email,
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
            
            //        GIDSignIn.sharedInstance.sign
            
            GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { signInResult, error in
                Task {
                    do {
                        guard let result = signInResult else {
                            // Inspect error
                            return
                        } 
                        
                        // If sign in succeeded, display the app's main content View.
                        let user = result.user
                        try await AuthService(appState: appState).createUserAccountFromGoogleIfNeeded(for: user)
                        //create firebase user if necessary
                        
                        self.alertErrorMessage = "Successfully signed in with Google user: \(user.idToken?.tokenString ?? "")"
                        self.isShowingLogInAlert = true
                    }
                    catch {
                        //do stuff
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
