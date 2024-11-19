//
//  ChecklistItem.swift
//  ListLoop
//
//  Created by Steve Parker on 11/2/24.
//

import Foundation
import SwiftUI
import SwiftData

@Model
final class ChecklistItem: Identifiable {
    private(set) var taskID: String = UUID().uuidString
    var name: String = ""
    var creationDate: Date = Date.now
    var isComplete: Bool = false
    var priority: Priority = Priority.normal
    var order: Int = 0 // To control the order of items in the list
    
    @Relationship(inverse: \Checklist.items)
    var checklist: Checklist?

    var id: String { taskID }
    
    init(name: String, order: Int) {
        self.name = name
        self.order = order
    }

    func toggleComplete() {
        isComplete.toggle()
    }
}

enum Priority: Int, Codable, CaseIterable {
    case low = 3
    case normal = 2
    case high = 1
    
    var name: String {
        switch self {
        case .low: return "Low"
        case .normal: return "Normal"
        case .high: return "High"
        }
    }
    
    var color: Color {
        switch self {
        case .low: return .blue
        case .normal: return .green
        case .high: return .red
        }
    }
}
