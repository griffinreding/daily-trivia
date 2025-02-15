//
//  Item.swift
//  daily-trivia
//
//  Created by GReding on 2/15/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
