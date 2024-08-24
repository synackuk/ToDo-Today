//
//  ButtonWithFrame.swift
//  LifeLog
//
//  Created by Douglas Inglis on 02/05/2023.
//

import SwiftUI

struct ButtonWithFrame<Content: View>: View {
    let title: String
    let action: () -> Void
    @ViewBuilder let frame: Content
    var body: some View {
        Button(action: action, label: {
            
            HStack(spacing:5) {
                
                /* Button Title */
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color(.label))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 10)
                
                /* Stack the Rounded Rectangle, with the image frame on top */
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color(.systemFill))
                        .frame(width:45, height:45)
                    
                    frame
                        .frame(width:30, height:30)
                    
                }
                .frame(maxWidth: .infinity, alignment: .trailing)
                .padding(.trailing)
            }
        })
        .frame(height:55)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        
    }
}

struct ButtonWithFrame_Previews: PreviewProvider {
    static var previews: some View {
        ButtonWithFrame(title:"Test", action:{}, frame: {Image(systemName: "bed.double")})
    }
}
