//
//  Store.swift
//  ListLoop
//
//  Created by Steve Parker on 11/3/24.
//

import Foundation
import StoreKit

@MainActor
class Store: ObservableObject {
    @Published var infListsUnlocked: Bool = false
    @Published var products: [Product] = []
    @Published var isPurchasing: Bool = false
    @Published var isPurchased: Bool = false
    @Published var error: Error?
    @Published var purchasedIDs = Set<String>()
    
    private var productIDs = ["infLists"]
    
    private var updates: Task<Void, Never>? = nil
    
    init() {
        updates = watchForUpdates()
    }
    
    func loadProducts() async {
        guard !productIDs.isEmpty else {
            print("No product IDs available to load.")
            return
        }
        print("Loading products: \(productIDs)")
        
        do {
            products = try await Product.products(for: productIDs)
            products.sort { $0.id < $1.id }
            print("Products loaded: \(products.map { $0.id })")
        } catch {
            print("Couldn't load products: \(error)")
            self.error = error
        }
    }
    
    func purchase(_ product: Product) async {
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success:
                isPurchased = true
                purchasedIDs.insert(product.id)
            case .pending:
                isPurchasing = true
                print("Purchase is pending.")
                break
            case .userCancelled:
                break
            @unknown default:
                break
            }
        } catch {
            print("Couldn't purchase \(product): \(error)")
        }
    }
    
    private func checkPurchased() async {
        for product in products {
            guard let state = await product.currentEntitlement else { return }
            
            switch state {
            case .unverified(let signedType, let verificationError):
                print("Error on \(signedType): \(verificationError)")
            case .verified(let signedType):
                if signedType.revocationDate == nil {
                    purchasedIDs.insert(signedType.productID)
                } else {
                    purchasedIDs.remove(signedType.productID)
                }
            }
        }
    }
    
    private func watchForUpdates() -> Task<Void, Never> {
        Task(priority: .background) {
            for await _ in Transaction.updates {
                await checkPurchased()
            }
        }
    }
}
