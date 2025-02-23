//
//  LeaderboardEntry.swift
//  daily-trivia
//
//  Created by GReding on 2/22/25.
//

import Foundation

struct LeaderboardEntry: Codable, Identifiable {
    var id: UUID = .init()
    var username: String
    var value: Int
}
