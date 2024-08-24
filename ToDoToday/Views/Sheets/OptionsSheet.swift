//
//  OptionsSheet.swift
//  ToDo, Today
//
//  Created by Douglas Inglis on 28/06/2023.
//

import SwiftUI

struct OptionsSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    @State private var showingBuySheet: Bool = false
    
    
    @StateObject private var preferences = Preferences.shared
    var body: some View {
        NavigationStack {
            VStack {
                
                /* Pro purchase */
                Button(action:{showingBuySheet = true}, label: {
                    HStack {
                        Text(preferences.isProUser ? "Thanks for buying pro!" : "Purchase ToDo, Today pro")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        if preferences.isProUser {
                            Image(systemName: "checkmark.circle.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.white)
                                .frame(width:30, height:30)
                        }
                        
                    }
                    .padding()
                })
                .frame(height:55)
                .background(preferences.isProUser ? .green : .accentColor)
                .cornerRadius(12)
                
                Spacer()
                /* Developer notes */
                
                Text("\(Bundle.main.object(forInfoDictionaryKey: "CFBundleName")! as! String) - \(Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")! as! String)")
                    .font(.subheadline)
                    .frame(maxWidth:.infinity, alignment: .leading)
                
                Text("Created by Douglas Inglis.")
                    .font(.subheadline)
                    .frame(maxWidth:.infinity, alignment: .leading)
                Text("Copyright © 2023 Douglas Inglis")
                    .font(.subheadline)
                    .frame(maxWidth:.infinity, alignment: .leading)
                Label {
                    Text("https://douglasinglis.dev")
                        .font(.subheadline)
                } icon: {
                    Image(systemName: "globe")
                }
                .frame(maxWidth:.infinity, alignment: .leading)
                
                Label {
                    Text("me@douglasinglis.dev")
                        .font(.subheadline)
                } icon: {
                    Image(systemName: "envelope.fill")
                }
                .frame(maxWidth:.infinity, alignment: .leading)
                
            }
            .padding()
            
            .navigationDestination(
                isPresented: $showingBuySheet) {
                    BuyProSheet(dismiss: _dismiss)
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

struct OptionsSheet_Previews: PreviewProvider {
    static var previews: some View {
        OptionsSheet()
    }
}
