//
//  PurchasePreferences.swift
//  ToDo, Today
//
//  Created by Douglas Inglis on 28/06/2023.
//

import Foundation
import StoreKit


class PurchasePreferences: ObservableObject {
    static var shared = PurchasePreferences()
    
    static let subscriptionIDs = ["ToDoToday1Month"]
    static let lifetimeID = "ToDoTodayLife"
    static let productIDs = [lifetimeID] + subscriptionIDs

    @Published var products = [Product] ()
    @Published var purchasedProducts: [String] = []
    @Published var isProUser: Bool = false
    
    
    private var detachedTask: Task = Task {}
    
    func purchase(_ item: Product) async {
        do {
            let result = try await item.purchase()
            switch result {
            case let .success(.verified(transaction)):
                // Successful purhcase
                await transaction.finish()
                await self.load()
            case .success(.unverified(_, _)):
                // Successful purchase but transaction/receipt can't be verified
                // Could be a jailbroken phone
                break
            case .pending:
                print("Transaction is pending for some action from the users related to the account")
            case .userCancelled:
                print("Use cancelled the transaction")
            default:
                print("Unknown error")
            }
        } catch {
            print(error)
        }
    }
    
    func load() async {
        await loadProducts()
        await loadPurchased()
        DispatchQueue.main.sync {
            #if DEBUG
            self.isProUser = true
            #else
            self.isProUser = self.purchasedProducts.count > 0
            #endif
        }
        
    }

    private func loadProducts() async {
        DispatchQueue.main.sync {
            self.products = []
        }
        do {
            let newProducts = try await Product.products(for: PurchasePreferences.productIDs).sorted(by: { $0.price < $1.price })
            DispatchQueue.main.sync {
                self.products = newProducts
            }
        }
        catch {
            print(error)
        }
    }
    
    private func loadPurchased() async {
        DispatchQueue.main.sync {
            self.purchasedProducts = []
        }
        
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            if transaction.revocationDate != nil {
                continue
            }
            DispatchQueue.main.sync {
                self.purchasedProducts.append(transaction.productID)
            }
        }
    }
    
    
    init() {
        detachedTask = Task.detached {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    await self.load()
                }
            }
        }
    }
    
    
    deinit {
        detachedTask.cancel()
    }
    
}
