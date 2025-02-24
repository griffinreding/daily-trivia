//
//  ManualReviewView.swift
//  daily-trivia
//
//  Created by GReding on 2/22/25.
//

import SwiftUI

enum ManualReviewAlert: Identifiable {
    case error, recordExists, confirmation
    
    var id: Int {
        hashValue
    }
}

struct ManualReviewView: View {
    @State private var userNote: String = ""
    @State private var errorMessage: String = ""
    @State private var activeAlert: ManualReviewAlert?
    @State private var isShowingRecordAlreadyExistsAlert = false
    @State private var isShowingConfirmationAlert = false
    
    
    let submittedAnswer: SubmittedAnswer
    let correctAnswer: String
    let username: String
    let question: String
    let streak: Int
    
    var dismiss: (() -> Void)
    
    var body: some View {
        VStack {
            Text("Submit your answer for manual review")
                .font(.title)
                .padding()
            
            Text("Your answer, \(submittedAnswer.userAnswer), was incorrect.")
                .padding()
            
            TextField("Enter a note for the reviewer (optional)", text: $userNote)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            
            Button {
                Task {
                    await submitForManualReview()
                }
            } label: {
                Text("Submit")
                    .padding(12)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.blue, lineWidth: 2)
                    }
            }
            .alert(item: $activeAlert) { alertType in
                        switch alertType {
                        case .error:
                            return Alert(
                                title: Text("Error"),
                                message: Text("There was an error submitting your answer for manual review. Please try again later.\n\nError: \(errorMessage)"),
                                dismissButton: .default(Text("OK"))
                            )
                        case .recordExists:
                            return Alert(
                                title: Text("Record Already Exists"),
                                message: Text("You have already submitted an answer for review today. I'll take a look, and update your answer result if necessary."),
                                dismissButton: .default(Text("OK"), action: {
                                    dismiss()
                                })
                            )
                        case .confirmation:
                            return Alert(
                                title: Text("Submitted for Review"),
                                message: Text("Your answer has been submitted for manual review. I'll take a look, and update your answer result if necessary."),
                                dismissButton: .default(Text("OK"), action: {
                                    dismiss()
                                })
                            )
                        }
                    }
        }
    }
    
    @MainActor
    func submitForManualReview() async {
        do {
            if try await GameService().submitAnswerForManualReview(submittedAnswer: submittedAnswer,
                                                                   username: username,
                                                                   question: question,
                                                                   correctAnswer: correctAnswer,
                                                                   userNote: userNote,
                                                                   streak: streak,
                                                                   outcome: submittedAnswer.answerOutcome) {
                activeAlert = .confirmation
            }
            else {
                activeAlert = .recordExists
            }
        } catch {
            errorMessage = error.localizedDescription
            activeAlert = .error
        }
    }
}

#Preview {
    ManualReviewView(submittedAnswer: SubmittedAnswer(date: "123456",
                                                      answerOutcome: true,
                                                      userAnswer: "asf"),
                     correctAnswer: "asdf",
                     username: "nmvnnv",
                     question: "ewrwer",
                     streak: 5,
                     dismiss: {
        print("dismiss")
    })
}

