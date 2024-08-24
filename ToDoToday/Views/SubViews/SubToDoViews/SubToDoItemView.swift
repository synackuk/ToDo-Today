//
//  SubToDoView.swift
//  LifeLog
//
//  Created by Douglas Inglis on 13/05/2023.
//

import SwiftUI

struct SubToDoItemView: View {
    @Binding var model: SubToDoItem
    @State private var update: Bool = false
    var body: some View {
        HStack {
            
            /* Set image depending on whether the item is completed */
            Image(systemName: model.completed ? "checkmark.square.fill" : "square")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:20, height:20)
                .onTapGesture {
                    if model.title.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                        model.completed.toggle()
                        
                        /* Crude hack, forces an update */
                        update.toggle()
                }
            }
                .animation(.easeInOut, value: model.completed)
            .padding(.leading)
            .padding(.vertical)

            /* Text field for the contents of the ToDo */
            TextField("What is the next step?", text:$model.title)
        }
        .frame(height:30)
    }
}

struct SubToDoItemView_Previews: PreviewProvider {
    @State static var model: SubToDoItem = SubToDoItem()
    
    static var previews: some View {
        SubToDoItemView(model: $model)
    }
}
