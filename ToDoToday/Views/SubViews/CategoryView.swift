//
//  CategoryView.swift
//  LifeLog
//
//  Created by Douglas Inglis on 26/05/2023.
//

import SwiftUI

struct CategoryView: View {
    @Binding var title: String
    @Binding var selected: Bool
    @State var locked: Bool = false
    var body: some View {
        HStack {
            
            /* Set image depending on whether the category is selected */
            Image(systemName: selected ? "checkmark.square.fill" : "square")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:20, height:20)
                .onTapGesture {
                if title.trimmingCharacters(in: .whitespacesAndNewlines) != "" {
                    selected.toggle()
                }
            }
            .animation(.easeInOut, value: selected)
            .padding(.leading)
            .padding(.vertical)
            
            /* Text field for the name of the category */
            TextField("Category name", text:$title)
                .disabled(locked)
        }
        .frame(height:30)
        .padding(5)
        .onChange(of: title, perform: { newValue in
            ToDoDataController.shared.save()
        })
    }
}
struct CategoryView_Previews: PreviewProvider {
    @State static var title = "Test"
    @State static var selected = true
    static var previews: some View {
        CategoryView(title: $title, selected: $selected)
    }
}
