//
//  ChecklistDetailView.swift
//  ListLoop
//
//  Created by Steve Parker on 11/2/24.
//

import SwiftUI
import SwiftData
import TipKit

struct ChecklistDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var checklist: Checklist
    @State private var newItemName: String = ""
    @State private var showingAddItemAlert = false
    @State private var shouldRotate = false
    @State private var addBounce = false
    @State private var sortOrder: SortOrder = .manual
        
    enum SortOrder {
        case manual
        case alphabetical
        case byCreationDate
        case byPriority
    }
    
    private var incompleteCount: Int {
        checklist.items?.filter { !$0.isComplete }.count ?? 0
    }

    private var completedCount: Int {
        checklist.items?.filter { $0.isComplete }.count ?? 0
    }

    var body: some View {
        // MARK: List
        VStack {
            Picker("Sort Order", selection: $sortOrder) {
                Text("Manual").tag(SortOrder.manual)
                Text("Alphabetical").tag(SortOrder.alphabetical)
                Text("Creation").tag(SortOrder.byCreationDate)
                Text("Priority").tag(SortOrder.byPriority)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            List {
                Section(header: Text("Incomplete" + (incompleteCount > 0 ? " (\(incompleteCount))" : ""))) {
                    ForEach(sortedItems(filterCompleted: false)) { item in
                        ChecklistItemView(item: item)
                    }
                    .onDelete(perform: deleteIncompleteItems)
                    .onMove(perform: moveItems)
                }
                
                Section(header: Text("Completed" + (completedCount > 0 ? " (\(completedCount))" : ""))) {
                    ForEach(sortedItems(filterCompleted: true)) { item in
                        ChecklistItemView(item: item)
                    }
                    .onDelete(perform: deleteCompletedItems)
                    .onMove(perform: moveItems)
                }
            }
            .task {
                try? Tips.configure()
            }
            .navigationTitle(checklist.name)
            // MARK: Toolbar
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            resetList()
                        }, label: {
                            if #available(iOS 18.0, *) {
                                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill")
                                    .symbolEffect(.rotate.byLayer, options: .nonRepeating, value: shouldRotate)
                                    .fontWeight(.light)
                                    .font(.system(size:42))
                            } else {
                                Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90.circle.fill")
                                    .symbolEffect(.bounce, options: .nonRepeating, value: shouldRotate)
                                    .fontWeight(.light)
                                    .font(.system(size:42))
                            }
                        })
                        .popoverTip(ResetTip(), arrowEdge: .top)
                        
                        Spacer()
                        
                        Button(action: addItem) {
                            Image(systemName: "plus.circle.fill")
                                .symbolEffect(.bounce, value: addBounce)
                                .fontWeight(.light)
                                .font(.system(size:42))
                        }
                        
                        Spacer()
                    }
                }
            }
            .alert("Add New Item", isPresented: $showingAddItemAlert) {
                TextField("Item Name", text: $newItemName)
                Button("Add", action: addItem)
                Button("Cancel", role: .cancel) { }
            }
        }
    }

    // MARK: Functions
    private func addItem() {
        showingAddItemAlert = true
        addBounce.toggle()
        
        guard !newItemName.isEmpty else { return }
        let order = checklist.items?.count ?? 0
        let newItem = ChecklistItem(name: newItemName, order: order)
        if checklist.items == nil {
            checklist.items = []
        }
        checklist.items?.append(newItem)
        newItemName = ""
    }
    
    private func resetList() {
        withAnimation {
            checklist.resetItems()
            shouldRotate.toggle()
        }
    }

    private func deleteIncompleteItems(at offsets: IndexSet) {
        withAnimation {
            let itemsToDelete = offsets.map { sortedItems(filterCompleted: false)[$0] }
            
            for item in itemsToDelete {
                print("Deleting ChecklistItem with ID: \(item.taskID) and Name: \(item.name)")
                modelContext.delete(item)
            }
        }
    }

    private func deleteCompletedItems(at offsets: IndexSet) {
        withAnimation {
            let itemsToDelete = offsets.map { sortedItems(filterCompleted: true)[$0] }
            
            for item in itemsToDelete {
                print("Deleting ChecklistItem with ID: \(item.taskID) and Name: \(item.name)")
                modelContext.delete(item)
            }
        }
    }

    private func moveItems(from source: IndexSet, to destination: Int) {
        checklist.items?.move(fromOffsets: source, toOffset: destination)
        
        // Update order values to reflect the new positions
        guard let items = checklist.items else { return }
        for index in items.indices {
            items[index].order = index
        }
    }
    
    private func sortedItems(filterCompleted: Bool) -> [ChecklistItem] {
        return (checklist.items?
            .filter { $0.isComplete == filterCompleted }
            .sorted(by: {
                switch sortOrder {
                case .manual:
                    return $0.order < $1.order
                case .alphabetical:
                    return $0.name < $1.name
                case .byCreationDate:
                    return $0.creationDate < $1.creationDate
                case .byPriority:
                    return ($0.priority.rawValue, $0.order) < ($1.priority.rawValue, $1.order)
                }
            })
        ) ?? []
    }
}

// MARK: Preview
#Preview {
    var testChecklist: Checklist {
        let checklist = Checklist(name: "Test Checklist")
        checklist.items = [
            ChecklistItem(name: "Buy groceries", order: 0),
            ChecklistItem(name: "Call John", order: 1),
            ChecklistItem(name: "Finish report", order: 2),
            ChecklistItem(name: "Book flight tickets", order: 3)
        ]
        return checklist
    }

    return ChecklistDetailView(checklist: testChecklist)
        .modelContainer(for: Checklist.self, inMemory: true)
}
