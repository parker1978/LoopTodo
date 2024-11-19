//
//  Item.swift
//  LoopTodo
//
//  Created by Steve Parker on 11/19/24.
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
