//
//  ListRowView.swift
//  LifeLog
//
//  Created by Douglas Inglis on 30/04/2023.
//

import SwiftUI

struct ToDoItem: View {
    @StateObject var model: ToDoModel
    @State private var isBeingEdited: Bool = false
    @State private var isBeingCopied: Bool = false
    
    @StateObject private var mainModel = ToDoViewModel.shared
    @StateObject private var preferences = Preferences.shared
    var body: some View {
        HStack {
            ToDoItemIconView(model: model)
                .frame(maxWidth: 60, maxHeight: .infinity)
            
            HStack {
                ToDoItemInformationView(model: model)
                Spacer()
                
                /* Show a progress indicator for our item */
                CircularProgressIndicator(model: model)
                    .frame(width: 50, height: 50)
                    .padding()
                    .contentShape(Circle())
                    .onTapGesture {
                        DispatchQueue.main.async {
                            model.makeProgress()
                            mainModel.update()
                        }
                    }
            }
            .animation(.easeInOut, value: model.goal)
            .frame(maxHeight: .infinity)
            .background(Color(.secondarySystemBackground).cornerRadius(12))
        }
        .animation(.easeInOut, value: model.goal)
        .fixedSize(horizontal: false, vertical: true)
        .contentShape(Rectangle())
        .onTapGesture {
            
            /* Open the correct popup */
            switch(preferences.homeScreenMode) {
            case .normal:
                isBeingEdited = true
                break
            case .copy:
                isBeingCopied = true
                break
            case .shunt:
                if model.timeSheduled {
                    ShuntPopup(startModel: model).showAndStack()
                }
                break
            }
            /* Reset the mode */
            preferences.homeScreenMode = .normal
            
            
        }
                
        .onDrag {
            preferences.draggedModel = model
            return ToDoItemProvider(item: NSString(), typeIdentifier: "com.synackuk.LifeLog.customtype.dragdroptype")
        }
    
        .onDrop(of: ["com.synackuk.LifeLog.customtype.dragdroptype"], delegate: ToDoDropDelegate(isbeingSheduled: model.timeSheduled, startTime: model.timeSheduled ? model.endDate : .distantPast, timeDelta: preferences.getDraggedModelTimeDelta(), isShowing: Binding.constant(false)))
        
        /* Hack to allow us to edit the items by tapping on them */
        .navigationDestination(
            isPresented: $isBeingEdited) {
                newToDoView(ID: model.ID, titleFieldText: model.title, notesTextField: model.notes, subToDoItems: model.subToDoItems.recreatedArray, chosenColour: model.toDoColour, chosenImage: model.icon, startDate: model.startDate, endDate: model.endDate, isTimeScheduled: model.timeSheduled, isDateScheduled: model.dateSheduled, isLocked: model.locked, completedUnits: model.completedUnits, autocomplete: model.autocomplete, toDoType: model.toDoType, repeatHandler: RepeatHandler(handler: model.repeatHandler), notificationDates: model.notificationDates, progress: model.progress, categories: model.categories)
            }
            .navigationDestination(
                isPresented: $isBeingCopied) {
                    newToDoView(ID: "", titleFieldText: model.title, notesTextField: model.notes, subToDoItems: model.subToDoItems.recreatedArray, chosenColour: model.toDoColour, chosenImage: model.icon, startDate: model.startDate, endDate: model.endDate, isTimeScheduled: model.timeSheduled, isDateScheduled: model.dateSheduled, isLocked: model.locked, completedUnits: model.completedUnits, autocomplete: model.autocomplete, toDoType: model.toDoType, repeatHandler: RepeatHandler(handler: model.repeatHandler), notificationDates: model.notificationDates, progress: 0, categories: model.categories.map({$0}))
                }
    }
    
}

struct ToDoItem_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ToDoItem(model: ToDoModel(ctx: ToDoDataController.shared.viewContext, title: "Heyo", icon: "pencil"))
        }
    }
}
