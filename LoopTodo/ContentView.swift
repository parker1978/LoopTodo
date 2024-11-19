//
//  ContentView.swift
//  ListLoop
//
//  Created by Steve Parker on 11/1/24.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject private var store: Store
    @Query private var checklists: [Checklist]
    @State private var newChecklistName: String = ""
    @State private var showingAddChecklistAlert = false
    @State private var showingUnlockAlert = false
    @State private var sortOrder: SortOrder = .alphabetical
    @State private var showSortOrderText = false
    @State private var addBounce = false
    
    private var unlockedMoreThanThree: Bool {
        store.purchasedIDs.contains("infList")
    }
    
    private var canAddChecklist: Bool {
        checklists.count < 3 || unlockedMoreThanThree
    }

    enum SortOrder {
        case alphabetical
        case byCreationDate
    }
    
    var sortedChecklists: [Checklist] {
        switch sortOrder {
        case .alphabetical:
            return checklists.sorted { $0.name < $1.name }
        case .byCreationDate:
            return checklists.sorted { $0.creationDate < $1.creationDate }
        }
    }

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(sortedChecklists) { checklist in
                    NavigationLink {
                        ChecklistDetailView(checklist: checklist)
                    } label: {
                        Text(checklist.name)
                    }
                }
                .onDelete(perform: deleteChecklists)
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button(action: unlock) {
                        Image(systemName: unlockedMoreThanThree ? "lock.open.fill" : "lock.fill")
                    }
                    .disabled(unlockedMoreThanThree)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    if showSortOrderText {
                        Text(sortOrder == .alphabetical ? "Alphabetical" : "By Creation Date")
                            .font(.caption)
                            .padding(4)
                            .background(Color.gray.opacity(0.8))
                            .cornerRadius(8)
                            .foregroundColor(.white)
                            .transition(.opacity.combined(with: .slide))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: toggleSortOrder) {
                        Image(systemName: (sortOrder == .alphabetical) ? "calendar" : "character.square")
                            .contentTransition(.symbolEffect(.replace.upUp.byLayer, options: .nonRepeating))
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        if canAddChecklist {
                            showingAddChecklistAlert = true
                        } else {
                            showingUnlockAlert = true
                            print("Cannot add more checklists without purchasing")
                        }
                    }, label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolEffect(.bounce, value: addBounce)
                            .fontWeight(.light)
                            .font(.system(size:42))
                    })
                }
            }
        } detail: {
            Text("Select a checklist")
        }
        .alert("New Checklist", isPresented: $showingAddChecklistAlert) {
            TextField("Checklist Name", text: $newChecklistName)
            Button("Add", action: addChecklist)
            Button("Cancel", role: .cancel) { }
        }
        .alert("Checklist Limit Reached", isPresented: $showingUnlockAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("You have reached the maximum of 3 checklists. Purchase the full version to add unlimited checklists.")
        }
        .preferredColorScheme(.dark)
    }
    
    
    private func toggleSortOrder() {
        sortOrder = (sortOrder == .alphabetical) ? .byCreationDate : .alphabetical
        print("Sort order toggled to \(sortOrder == .alphabetical ? "alphabetical" : "creation date")")
        
        // Show the sort order text with animation
        withAnimation {
            showSortOrderText = true
        }
        
        // Hide the sort order text after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showSortOrderText = false
            }
        }
    }
    
    private func unlock() {
        guard !store.products.isEmpty else {
            print("Products not loaded")
            return
        }
        
        guard let product = store.products.first(where: { $0.id == "infList" }) else {
            print("Product not found")
            return
        }
        
        Task {
            await store.purchase(product)
        }
    }

    private func addChecklist() {
        guard !newChecklistName.isEmpty else { return }
        withAnimation {
            let newChecklist = Checklist(name: newChecklistName)
            modelContext.insert(newChecklist)
            newChecklistName = ""
        }
    }

    private func deleteChecklists(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                let checklistToDelete = sortedChecklists[index]
                let checklistID = checklistToDelete.checklistID
                
                print("Deleting Checklist with ID: \(checklistID) and Name: \(checklistToDelete.name)")
                
                modelContext.delete(checklistToDelete)
            }
        }
    }
}

#Preview {
    let previewStore = Store()
    ContentView()
        .environmentObject(previewStore)
        .modelContainer(for: Checklist.self, inMemory: true)
}
