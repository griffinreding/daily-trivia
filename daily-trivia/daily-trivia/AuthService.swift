//
//  AuthService.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import Foundation
import Firebase
import FirebaseAuth
import GoogleSignIn

class AuthService {
    static let shared = AuthService()
    
    func signUp(email: String, password: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("Sign Up Error: \(error.localizedDescription)")
            } else {
                print("User signed up with uid: \(result?.user.uid ?? "")")
            }
        }
    }
    
    func signIn(email: String, password: String) async throws -> User {
        try await withCheckedThrowingContinuation { continuation in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else if let user = authResult?.user {
                    continuation.resume(returning: User(firebaseUser: user))
                } else {
                    let unknownError = NSError(domain: "SignInError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown error occurred"])
                    continuation.resume(throwing: unknownError)
                }
            }
        }
    }
    
//    func signInWithGoogle() {
//            // Retrieve the clientID from Firebase configuration.
//            guard let clientID = FirebaseApp.app()?.options.clientID else {
//                print("Missing client ID")
//                return
//            }
//            
//            // Create a GIDConfiguration with your client ID.
//            let config = GIDConfiguration(clientID: clientID)
//            
//            // Get the root view controller to present the Google Sign-In UI.
//            guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
//                  let rootVC = windowScene.windows.first?.rootViewController else {
//                print("Unable to get root view controller.")
//                return
//            }
//            
//            // Start the sign-in flow.
//            GIDSignIn.sharedInstance.signIn(with: config, presenting: rootVC) { user, error in
//                if let error = error {
//                    print("Google Sign-In Error: \(error.localizedDescription)")
//                    return
//                }
//                
//                guard let authentication = user?.authentication,
//                      let idToken = authentication.idToken else {
//                    print("Failed to get authentication tokens.")
//                    return
//                }
//                
//                // Create a Firebase credential.
//                let credential = GoogleAuthProvider.credential(withIDToken: idToken,
//                                                               accessToken: authentication.accessToken)
//                
//                // Sign in to Firebase with the Google credential.
//                Auth.auth().signIn(with: credential) { authResult, error in
//                    if let error = error {
//                        print("Firebase Sign-In Error: \(error.localizedDescription)")
//                    } else if let user = authResult?.user {
//                        print("User signed in with Google: \(user.uid)")
//                        // Transition to the main app view here, e.g., update an app state.
//                    }
//                }
//            }
//        }
}
