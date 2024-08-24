//
//  ToDoItem.swift
//  ToDo, Today Watch App
//
//  Created by Douglas Inglis on 18/06/2023.
//

import SwiftUI

struct ToDoItem: View {
    @StateObject var model: ToDoModel
    @StateObject var dataController = ToDoDataController.shared
    var body: some View {
        HStack {
            ToDoItemIconView(model: model, frameWidth: 20)
                .frame(width: 20)
            HStack {
                ToDoItemInformationView(model: model, watchView: true)
                Spacer()
                CircularProgressIndicator(model: model)
                    .frame(width:30, height:30)
                    .contentShape(Circle())
                    .onTapGesture {
                        DispatchQueue.main.async {
                            model.makeProgress()
                            dataController.update()
                        }
                    }
                    .padding(.trailing, 5)
            }
            .frame(maxWidth: .infinity)
            .background(Color(white: 0.19).cornerRadius(12))

        }
        .fixedSize(horizontal: false, vertical: true)

    }
}

struct ToDoItem_Previews: PreviewProvider {
    static var previews: some View {
        ToDoItem(model: ToDoModel(ctx: ToDoDataController.shared.viewContext, title: "Test", icon: "cup.and.saucer", toDoColour: .blue, timeSheduled: true, dateSheduled: true))
    }
}
