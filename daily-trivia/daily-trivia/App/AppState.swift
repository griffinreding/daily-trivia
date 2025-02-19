//
//  AppState.swift
//  daily-trivia
//
//  Created by GReding on 2/18/25.
//


import SwiftUI
import FirebaseAuth

class AppState: ObservableObject {
    @Published var isUserLoggedIn: Bool = false
    @Published var currentUser: User?
}
