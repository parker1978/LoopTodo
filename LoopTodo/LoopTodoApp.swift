//
//  ListLoopApp.swift
//  ListLoop
//
//  Created by Steve Parker on 11/1/24.
//

import SwiftUI
import SwiftData

@main
struct ListsLoopApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Checklist.self,
            ChecklistItem.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("Error creating ModelContainer: \(error.localizedDescription)")
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    @StateObject private var store = Store()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .task {
                    await store.loadProducts()
                }
        }
        .modelContainer(sharedModelContainer)
    }
}

// Bugs Found so far
//
// ✅ Deleting lists doesn't always delete the right list
// when sorted alpha
//
// ✅ Deleteing tasks doesn't always delete the correct
// task
//
// ✅ Make this app work for previous versions of iOS
//
// Version 2.0 Features
//
// ✅ Add priorities to task list items
//
// ✅ Move loop button to bottom toolbar
//
// ✅ Rename to: LoopTodo
//
// ✅ Update app icon
//
// Version 3.0 Features
//
// Background on main screen with a call to action
// when there are no active lists
//
// Templates as an option when adding a new list
//
// Count of how many time a list has been looped
//
// Version 4.0 Features
//
// Have a way to set a time or certain time of day
// to get a notification about a particular list.
