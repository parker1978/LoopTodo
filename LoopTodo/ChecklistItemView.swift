//
//  ChecklistItemView.swift
//  ListLoop
//
//  Created by Steve Parker on 11/2/24.
//

import SwiftUI
import SwiftData

// A view for displaying a single checklist item with a toggle for completion
struct ChecklistItemView: View {
    @Bindable var item: ChecklistItem

    var body: some View {
        HStack {
            //Priority menu
            Menu {
                ForEach(Priority.allCases, id: \.rawValue) { priority in
                    Button(action: { item.priority = priority }, label: {
                        HStack {
                            Text(priority.name)
                            
                            if item.priority == priority {
                                Image(systemName: "checkmark")
                            }
                        }
                    })
                }
            } label: {
                Image(systemName: "circle.fill")
                    .font(.title2)
                    .padding(3)
                    .contentShape(.rect)
                    .foregroundStyle(item.priority.color.gradient)
            }
            
            Text(item.name)
            
            Spacer()
            
            Button(action: { checkboxToggle() }) {
                Image(systemName: item.isComplete ? "checkmark.square.fill" : "square")
                    .font(.title)
            }
            .buttonStyle(BorderlessButtonStyle()) // Allows toggling without triggering the row selection
        }
    }
    
    private func checkboxToggle() {
        item.toggleComplete()
        giveFeedback()
    }

    private func giveFeedback() {
        let generator = UINotificationFeedbackGenerator()
        
        generator.notificationOccurred(.success)
    }
}

#Preview {
    ChecklistItemView(item: ChecklistItem(name: "Item", order: 1))
        .modelContainer(for: Checklist.self, inMemory: true)
}
