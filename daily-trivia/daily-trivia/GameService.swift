//
//  GameService.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import Foundation

class GameService {
    
    func fetchTodayQuestion() {
        guard let url = URL(string: "https://gettodayquestion-fo4koniylq-uc.a.run.app") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching question: \(error)")
                return
            }
            guard let data = data else { return }
            do {
                let question = try JSONDecoder().decode(TriviaQuestion.self, from: data)
                DispatchQueue.main.async {
                    // Update your UI with the question data
                    print("Question: \(question.question)")
                }
            } catch {
                print("Decoding Error: \(error)")
            }
        }.resume()
    }
    
    func submitAnswer(userId: String, userAnswer: String) {
        guard let url = URL(string: "https://submitanswer-fo4koniylq-uc.a.run.app") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let answerData: [String: Any] = [
            "userId": userId,
            "userAnswer": userAnswer
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: answerData, options: [])
        } catch {
            print("Error creating JSON data: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error submitting answer: \(error)")
                return
            }
            guard let data = data else { return }
            do {
                let response = try JSONDecoder().decode(SubmittedAnswer.self, from: data)
                DispatchQueue.main.async {
                    // Update your UI based on whether the answer was correct
//                    print("Answer Correct: \(response.correct)")
                }
            } catch {
                print("Error decoding response: \(error)")
            }
        }.resume()
    }
    
}

