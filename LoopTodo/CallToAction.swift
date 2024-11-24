//
//  CallToAction.swift
//  LoopTodo
//
//  Created by Steve Parker on 11/22/24.
//

import SwiftUI

struct CallToAction: View {
    @State var showSettings: Bool = false
    var action: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                Spacer()
                
                Button {
                    showSettings.toggle()
                } label: {
                    Image(systemName: "gear")
                        .font(.title)
                }
                .padding()
            }
            
            Spacer()
            
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("No Lists Yet")
                .font(.title)
                .fontWeight(.semibold)
            
            Text("Tap the button below to get started by adding your first list.")
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button {
                action()
            } label: {
                HStack {
                    Image(systemName: "plus.circle")
                        .font(.headline)
                    Text("Add List")
                        .font(.headline)
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .padding()
        .sheet(isPresented: $showSettings) {
            Settings()
        }
    }
}


#Preview {
    ContentView()
}
