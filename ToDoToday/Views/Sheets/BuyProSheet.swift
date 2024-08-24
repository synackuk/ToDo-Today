//
//  BuyProSheet.swift
//  ToDo, Today
//
//  Created by Douglas Inglis on 28/06/2023.
//

import SwiftUI
import StoreKit

struct BuyProSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @StateObject private var purchasePreferences = PurchasePreferences.shared
    @State private var isShowingWarning = false
    @State private var productToPurchaseAfterWarning: Product? = nil
    var body: some View {
        NavigationStack {
            VStack {
                Text("Get ToDo, Today pro")
                    .font(.largeTitle)
                Text("Features:")
                    .font(.title)
                    .frame(maxWidth:.infinity, alignment: .leading)
                Text("•\tMulti-Part and goal based lists\n•\tRepeatable items\n•\tNotifications")
                    .font(.title3)
                    .frame(maxWidth:.infinity, alignment: .leading)
                /* Buy Options */
                
                ForEach(purchasePreferences.products) { product in
                    if !PurchasePreferences.subscriptionIDs.contains(product.id) || !purchasePreferences.purchasedProducts.contains(PurchasePreferences.lifetimeID) {
                        Button(action:{
                            if product.id == PurchasePreferences.lifetimeID && Preferences.shared.isProUser {
                                productToPurchaseAfterWarning = product
                                isShowingWarning = true
                            }
                            else {
                                Task {
                                    await purchasePreferences.purchase(product)
                                }
                            }
                            
                            
                        }, label: {
                            Text("\(product.displayName) - \(product.displayPrice)")
                                .font(.title3)
                                .foregroundColor(Color(.white))
                                .frame(maxWidth: .infinity, alignment: .center)
                        })
                        .disabled(purchasePreferences.purchasedProducts.contains(product.id))
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(purchasePreferences.purchasedProducts.contains(product.id) ? .green : Color.accentColor)
                        .cornerRadius(12)
                    }
                }
                
                Button("Restore Purchases", action: {
                    Task.init {
                        try? await AppStore.sync()
                        await purchasePreferences.load()
                    }
                    
                })
                .padding(.vertical)
                
                Text("[Terms and Conditions](https://www.apple.com/legal/internet-services/itunes/dev/stdeula/), [Privacy Policy](https://www.app-privacy-policy.com/live.php?token=p7uOSS39Fx10IfDIcVsubn8J4ioHlNhm)")
                .padding(.top)
                
                Spacer()
                
            }
            .padding()
            
            /* Warning about lifetime subscription */
            .alert("Please note that you'll need to cancel your monthly subscription manually.", isPresented: $isShowingWarning) {
                Button("Understood", action: {
                    if productToPurchaseAfterWarning != nil {
                        Task {
                            await purchasePreferences.purchase(productToPurchaseAfterWarning!)
                        }

                    }
                })
            }

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {dismiss()}, label: {
                        /* Stack exit button elements */
                        ZStack(alignment: .topTrailing) {
                            
                            Circle()
                                .fill(Color(white: colorScheme == .dark ? 0.19 : 0.93))
                            
                            Image(systemName: "xmark")
                                .resizable()
                                .scaledToFit()
                                .font(Font.body.weight(.bold))
                                .scaleEffect(0.416)
                                .foregroundColor(Color(white: colorScheme == .dark ? 0.62 : 0.51))
                            
                        }
                        .frame(width: 24, height: 24)
                    })
                }
            }
        }
    }
}

struct BuyProSheet_Previews: PreviewProvider {
    static var previews: some View {
        BuyProSheet()
    }
}
