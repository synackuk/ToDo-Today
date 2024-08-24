//
//  ExitButtonView.swift
//  LifeLog
//
//  Created by Douglas Inglis on 01/06/2023.
//

import SwiftUI

struct ExitButtonView: View {
    @Environment(\.colorScheme) var colorScheme
    @State var dismiss: () -> ()

    var body: some View {
        /* Exit Button */
        HStack {
            
            /* Push exit to RHS */
            Spacer()
            
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
            .padding(.trailing)
            .onTapGesture {dismiss()}
            
        }
        .padding(.vertical, 25)
    }
}

struct ExitButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ExitButtonView(dismiss: {})
    }
}
