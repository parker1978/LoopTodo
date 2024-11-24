//
//  Settings.swift
//  LoopTodo
//
//  Created by Steve Parker on 11/20/24.
//

import SwiftUI
import StoreKit

struct Settings: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var constants: Constants
    @EnvironmentObject private var store: Store
    @State private var shadowRadius: CGFloat = 10
    @State private var shadowColor: Color = .white
    @State private var showRestoreAlert = false
    @State private var restoreMessage = ""
    @State private var purchaseStatus: PurchaseStatus = .notStarted
    
    enum PurchaseStatus {
        case notStarted
        case inProgress
        case success
        case failed(error: Error)
    }
    
    private var unlocked: Bool {
        store.purchasedIDs.contains("unlimited")
    }
    
    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Spacer()
                    
                    Button("Done") {
                        dismiss()
                    }
                    .font(.title2)
                }
                .padding()
                
                Spacer()
                
                Image(.loopTodo)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 200, height: 200)
                    .clipShape(.rect(cornerRadius: 25))
                    .shadow(color: shadowColor, radius: shadowRadius)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 1).repeatForever(autoreverses: true)) {
                            shadowRadius = 15
                            shadowColor = .blue
                        }
                    }
                
                Text("LoopTodo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                Text("This app is free to use with 3 lists.")
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                
                Text("If you'd like to support the app, you can subscribe and get unlimited lists!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .fixedSize(horizontal: false, vertical: true)
                    .padding()
                
                switch purchaseStatus {
                case .notStarted:
                    Button {
                        unlock()
                    } label: {
                        Text("Subscribe to Unlimited\nfor $4.99 per year")
                            .multilineTextAlignment(.center) // Optional: Centers the text
                    }
                    .padding()
                case .inProgress:
                    ProgressView()
                case .success:
                    Text("Thanks for your support! 🎉")
                        .font(.title3)
                        .padding()
                case .failed(error: let error):
                    Text(error.localizedDescription)
                }
                
                Button("Restore Purchases") {
                    restorePurchases()
                }
                .padding()
                .alert(isPresented: $showRestoreAlert) {
                    Alert(title: Text("Restore Purchases"), message: Text(restoreMessage), dismissButton: .default(Text("OK")))
                }
                
                Spacer()
                
                VStack {
                    Text("Keyboard Settings")
                        .font(.headline)
                    
                    Picker("Text Casing", selection: $constants.textCasing) {
                        ForEach(TextCasing.allCases) { casing in
                            Text(casing.rawValue).tag(casing)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    Toggle("Show Suggestions", isOn: $constants.showSuggestions)
                        .padding(.horizontal)
                }
                .padding()
                
                Text("© 2024 Steve Parker")
                    .padding(.top, 60)
                Text("https://www.parker1978.com")
                    .padding(.bottom, 40)
                                
                HStack {
                    Link("Terms of Use", destination: URL(string:"https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                        .foregroundColor(.blue)
                        .underline()
                        .font(.caption)
                    
                    Text("🟡")
                    
                    Link("Privacy Policy", destination: URL(string:"https://www.parker1978.com/privacy-policy-lla")!)
                        .foregroundColor(.blue)
                        .underline()
                        .font(.caption)
                }
                
            }
            .onAppear {
                if unlocked {
                    purchaseStatus = .success
                } else {
                    purchaseStatus = .notStarted
                }
            }
        }
    }
    
    private func unlock() {
        guard !store.products.isEmpty else {
            print("Products not loaded")
            return
        }
        
        guard let product = store.products.first(where: { $0.id == "unlimited" }) else {
            print("Product not found")
            return
        }
        
        Task {
            purchaseStatus = .inProgress
            do {
                // Call the purchase method, even if it doesn't return a value
                await store.purchase(product)
                
                // Check if the product is now marked as purchased
                if store.purchasedIDs.contains(product.id) {
                    purchaseStatus = .success
                } else {
                    purchaseStatus = .notStarted
                }
            } 
        }
    }
    
    private func restorePurchases() {
        Task {
            await store.checkPurchased()
            
            if store.purchasedIDs.isEmpty {
                restoreMessage = "Failed to restore purchases: No products found."
            } else {
                purchaseStatus = .success
                restoreMessage = "Purchases restored successfully!"
            }
            showRestoreAlert = true
        }
    }
}

#Preview {
    let previewStore = Store()
    let previewConstants = Constants()
    Settings()
        .environmentObject(previewStore)
        .environmentObject(previewConstants)
}
