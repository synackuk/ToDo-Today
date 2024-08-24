//
//  ButtonImage.swift
//  ToDo, Today
//
//  Created by Douglas Inglis on 08/06/2023.
//

import SwiftUI

func PlusButton() -> some View {
    return ButtonImage(imageName: "plus.circle.fill", size: 30, colour: Color(.label))
}


func DeleteButton() -> some View {
    return ButtonImage(imageName: "x.circle.fill", size: 20, colour: Color(.systemRed))
}

struct ButtonImage: View {
    @State var imageName: String
    @State var size: CGFloat
    @State var colour: Color
    var body: some View {
        Image(systemName: imageName)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(colour)
            .frame(width:size, height:size)
            .padding(.trailing)
    }
}

struct ButtonImage_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            PlusButton()
            DeleteButton()
        }
    }
}
