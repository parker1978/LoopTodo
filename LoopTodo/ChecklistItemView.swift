import SwiftUI
import SwiftData

// A view for displaying a single checklist item with a toggle for completion
struct ChecklistItemView: View {
    @Bindable var item: ChecklistItem
    @EnvironmentObject private var constants: Constants
    @State private var isEditingAlertPresented: Bool = false
    @State private var tempName: String = ""

    var body: some View {
        HStack {
            // Priority menu
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
                .onTapGesture {
                    tempName = item.name
                    isEditingAlertPresented = true
                }
            
            Spacer()
            
            Button(action: { checkboxToggle() }) {
                Image(systemName: item.isComplete ? "checkmark.square.fill" : "square")
                    .font(.title)
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        .alert("Edit Name", isPresented: $isEditingAlertPresented, actions: {
            TextField("Enter new name", text: $tempName)
                .textInputAutocapitalization(
                    constants.textCasing == .firstWord ? .sentences :
                        constants.textCasing == .allWords ? .words : .none
                    )
                .disableAutocorrection(!constants.showSuggestions)
            Button("OK") {
                item.name = tempName.trimmingCharacters(in: .whitespacesAndNewlines)
            }
            Button("Cancel", role: .cancel) {
                // Discard changes
            }
        })
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
    let previewConstatns = Constants()
    ChecklistItemView(item: ChecklistItem(name: "Item", order: 1))
        .modelContainer(for: Checklist.self, inMemory: true)
        .environmentObject(previewConstatns)
}
