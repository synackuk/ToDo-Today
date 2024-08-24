//
//  ContentView.swift
//  ToDo, Today Watch App
//
//  Created by Douglas Inglis on 18/06/2023.
//

import SwiftUI

struct ContentView: View {
    @StateObject var dataController = ToDoDataController.shared
    var body: some View {
        NavigationStack {
            ScrollView {
                HStack {
                    Button(action: {
                        dataController.currDate = dataController.currDate.addTime(day: -1)
                    }) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)

                    Text(dataController.currDate.formatDate(formatString: "dd/MM/yyyy"))
                        .font(.subheadline)
                        .foregroundColor(dataController.currDate.doDatesShareADay(date: Date()) ? .accentColor : .primary)
                    Button(action: {
                        dataController.currDate = dataController.currDate.addTime(day: 1)
                    }) {
                        Image(systemName: "chevron.forward")
                            .foregroundColor(.primary)
                    }
                    .buttonStyle(.plain)
                }
                VStack {
                    Text("To Do Items")
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top)
                        
                    VStack(spacing: 10) {
                        ForEach(dataController.toDoItems) { model in
                            ToDoItem(model: model)
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
                
                VStack {
                    Text("Timeline Items")
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 0) {
                        ForEach(dataController.timeBasedItems) { model in
                            let index = dataController.timeBasedItems.firstIndex(of: model)
                            if index != 0 {
                                TimelineSpacer(startModel: dataController.timeBasedItems[index! - 1], endModel: model, watchView: true)
                            }
                            ToDoItem(model: model)
                        }
                    }
                }
                .padding(.horizontal, 5)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
