//
//  SubToDoView.swift
//  LifeLog
//
//  Created by Douglas Inglis on 13/05/2023.
//

import SwiftUI

struct SubToDoView: View {
    @Binding var subToDoItems: [SubToDoItem]

    var body: some View {
        VStack {
            
            /* Button to add a new to do item */
            Button(action: {
                subToDoItems.append(SubToDoItem())
            }) {
                HStack {
                    Text("Add new item")
                        .font(.headline)
                        .foregroundColor(Color(.label))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.leading)
                    
                    PlusButton()
                }
            }
            .frame(height:55)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
            .padding(.bottom)
            List {
                
                /* For all the to do items */
                ForEach($subToDoItems) { item in
                    HStack {
                        
                        /* Show the to do item */
                        SubToDoItemView(model: item)
                        
                        /* Show a delete button */
                        DeleteButton()
                            .onTapGesture {
                                
                                /* Remove the to do item */
                                let index = subToDoItems.firstIndex(of: item.wrappedValue)
                                subToDoItems.remove(at: index!)
                            }
                    }
                    .listRowBackground(Color(.secondarySystemBackground))
                    .onDrag {
                        return NSItemProvider(item: NSString(), typeIdentifier: "com.synackuk.ToDoToday.customtype.dragdroptype")
                    }
                    .onDrop(of: ["com.synackuk.ToDoToday.customtype.dragdroptype"], delegate: SubToDoItemDropDelegate())
                }
                .onMove(perform: {subToDoItems.move(fromOffsets: $0, toOffset: $1)})
            }
            .frame(height: CGFloat(44 * subToDoItems.count))
            .listStyle(.plain)
            .cornerRadius(12)
            
        }
        
    }
}

struct SubToDoView_Previews: PreviewProvider {
    @State static var subToDoItems: [SubToDoItem] = []
    static var previews: some View {
        SubToDoView(subToDoItems: $subToDoItems)
    }
}
