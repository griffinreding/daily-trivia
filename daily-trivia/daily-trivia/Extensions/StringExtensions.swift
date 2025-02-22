//
//  StringExtensions.swift
//  daily-trivia
//
//  Created by GReding on 2/21/25.
//

extension String {
    func sanitizedEmail() -> String {
        return self
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "@", with: "_")
    }
}
