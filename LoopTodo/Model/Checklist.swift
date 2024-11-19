//
//  Checklist.swift
//  ListLoop
//
//  Created by Steve Parker on 11/2/24.
//

import Foundation
import SwiftData

@Model
final class Checklist: Identifiable {
    private(set) var checklistID: String = UUID().uuidString
    var name: String = ""
    var creationDate: Date = Date.now
    var items: [ChecklistItem]? = []
    
    var completedItems: [ChecklistItem] {
        return items?.filter { $0.isComplete } ?? []
    }

    var incompleteItems: [ChecklistItem] {
        return items?.filter { !$0.isComplete } ?? []
    }
    
    var id: String { checklistID }

    init(name: String) {
        self.name = name
    }

    func resetItems() {
        guard let items = items else { return }
        for item in items {
            item.isComplete = false
        }
    }
}
