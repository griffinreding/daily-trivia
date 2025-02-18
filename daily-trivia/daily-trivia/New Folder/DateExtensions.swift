//
//  DateExtensions.swift
//  daily-trivia
//
//  Created by GReding on 2/17/25.
//

import Foundation

extension Date {
    func dateFormattedForDb() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        return dateFormatter.string(from: self).replacingOccurrences(of: "-", with: "")
    }
}
