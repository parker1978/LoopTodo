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
    
    @StateObject private var constants = Constants()
    @StateObject private var store = Store()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
                .environmentObject(constants)
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
// ✅ Restore purchases option
//
// Subscription not included in app
//
// Version 1.0 Features
//
// ✅ Add priorities to task list items
//
// ✅ Move loop button to bottom toolbar
//
// ✅ Rename to: LoopTodo
//
// ✅ Update app icon
//
// Version 2.0 Features
//
// ✅ Tap on text to edit
//
// Use siri to add items
//
// Keyboard controls:
// * default case
// * suggestions on/off
//
// ✅ Call to action when no lists
//
// Show/Hide the item detail sections
//
// Templates as an option when adding a new list
//
// Version 3.0+ Features
//
// Stats for nerds:
// Count of how many times a list has been looped
// Calendar with usage day hotspots
//
// Have a way to set a time or certain time of day
// to get a notification about a particular list.
//
// Import / Export data
