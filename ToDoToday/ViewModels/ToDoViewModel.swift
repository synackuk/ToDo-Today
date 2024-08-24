//
//  ToDoViewModel.swift
//  LifeLog
//
//  Created by Douglas Inglis on 01/05/2023.
//

import Foundation
import SwiftUI
import CoreData
import WidgetKit

class ToDoViewModel: ObservableObject {
    static var shared = ToDoViewModel()
    @Published private var dataController: ToDoDataController = ToDoDataController.shared
    
    var all: Bool = true {
        didSet {
            
            /* If the all switch is flicked, clear out other fields */
            if all {
                showCompleted = false
                showNotCompleted = false
                showingCategories = []
            }
        }
    }
    
    var showCompleted: Bool = false
    
    var showNotCompleted: Bool = false
    
    var showingCategories: [Category] = []
    
    var currDate: Date {
        get {
            
            /* Pass through currDate from the data controller */
            dataController.currDate
        }
        set {
            
            /* Pass through currDate to the data controller */
            dataController.currDate = newValue
            
            /* Update the View Model */
            objectWillChange.send()
        }
    }
    
    var timeBasedItems: [ToDoModel] {
        get {
            
            /* Pass through the time based items */
            let fullList = dataController.timeBasedItems
            
            /* If we're taking it all then just return the full list */
            if all {
                return fullList.sortedTimeline
            }
            
            
            var outList: [ToDoModel] = []
            
            /* If we're showing completed items append those to the output */
            if showCompleted {
                outList.append(contentsOf: fullList.hasCompleted)
            }
            
            /* If we're showing uncompleted items append those to the output */
            if showNotCompleted {
                outList.append(contentsOf: fullList.hasNotCompleted)
            }
            
            /* Go through all the categories to be shown, add items in our category */
            for category in showingCategories {
                outList.append(contentsOf: fullList.hasCategory(category: category))
            }
            
            /* Sort the array and remove duplicates */
            return Array(Set(outList)).sortedTimeline
        }
    }
    
    var toDoItems: [ToDoModel] {
        get {
            
            /* Pass through the to do items */
            let fullList = dataController.toDoItems
            
            /* If we're taking it all then just return the full list */
            if all {
                return fullList.sortedToDo
            }
            
            var outList: [ToDoModel] = []
            
            /* If we're showing completed items append those to the output */
            if showCompleted {
                outList.append(contentsOf: fullList.hasCompleted)
            }
            
            /* If we're showing uncompleted items append those to the output */
            if showNotCompleted {
                outList.append(contentsOf: fullList.hasNotCompleted)
            }
            
            /* Go through all the categories to be shown, add items in our category */
            for category in showingCategories {
                outList.append(contentsOf: fullList.hasCategory(category: category))
            }
            
            /* Sort the array and Remove duplicates */
            return Array(Set(outList)).sortedToDo
            
        }
    }

    
    init() {
        
        /* Refresh the data controller on init */
        dataController.refresh()
        
    }
    
    
    func update() {
        
        /* Make sure our categories are setup properly */
        fixCategories()
        
        /* Update to the data controller */
        dataController.update()
        
        /* Refresh the view model */
        self.objectWillChange.send()
        
    }
        
    func saveToDo(ID: String, title: String, notes: String, icon: String, progress: Int, completedUnits: Int, toDoColour: Color, startDate: Date, endDate: Date, timeSheduled: Bool, dateSheduled: Bool, locked: Bool, repeatHandler: RepeatHandler, notificationDates: [Timedelta], categories: [Category], autocomplete: Bool, toDoType: ToDoType, subToDoItems: [SubToDoItem], repeatUpdateBehaviour: RepeatUpdateBehaviour) -> Bool {
        
        /* Verify that the title has been set */
        if(title.trimmingCharacters(in: .whitespacesAndNewlines) == "") {
            return false
        }
        
        /* Verify that the number of units to complete is greater than 0 */
        
        if(completedUnits <= 0) {
            return false
        }
        
        /* Verify that multipart to do items have some sub items */
        
        if(toDoType == .multiPart && subToDoItems.fixedList.count == 0) {
            return false
        }
        
        /* Verify that our repeat update behaviour isn't to cancel */
        if(repeatUpdateBehaviour == .cancel) {
            return false
        }
        
        /* Get a model for our ID, or if no such model exists, create a new one */
        let model = dataController.toDoForID(id: ID) ?? ToDoModel(ctx:ToDoDataController.shared.viewContext)
        
        /* If our model has a parent, keep the dates not to modify */
        if model.parentToDo != nil {
            repeatHandler.excludedDates = model.parentToDo!.repeatHandler.excludedDates
        }
        
        /* Setup a list of models to update */
        var modelsToUpdate = [model]
        
        /* Handle the repeats as elegently as possible */
        
        /* If we're updating more than one model (and our model is currently repeating) */
        if repeatUpdateBehaviour.rawValue >= RepeatUpdateBehaviour.futureUpdate.rawValue {
            
            /* If we're disabling repeats, delete the parent to stop repetition */
            if(repeatHandler.repeatClass == .none) {
                ToDoDataController.shared.viewContext.delete(model.parentToDo!)
            }
            else {
                
                /* Otherwise, update the parent model. */
                modelsToUpdate.append(model.parentToDo!)
            }
            
            /* Go through all the future models and assign them for updating */
            var nextToDo = model.nextToDo
            while(nextToDo != nil) {
                modelsToUpdate.append(nextToDo!)
                nextToDo = nextToDo!.nextToDo
            }
            
            /* If we're updating past models too */
            if repeatUpdateBehaviour == .allUpdate {
                
                /* Get all the past models and set them */
                modelsToUpdate = model.parentToDo!.childToDos!.allObjects as! [ToDoModel]
                modelsToUpdate.append(model.parentToDo!)
                
            }
            
        }
        else {
            
            /* If we're just updating this model, remove it from the sect of other repeating items. */
            model.unlinkFromRepeats()
        }
        
        for toDo in modelsToUpdate {
            
            /* Set all the relevent details */
            toDo.title = title
            toDo.icon = icon
            toDo.notes = notes
            toDo.completedUnits = toDoType == .singlePart ? 1 : completedUnits
            toDo.toDoColour = toDoColour
            toDo.locked = locked
            
            if toDo.toDoType != toDoType {
                toDo.progress = 0
            }
            toDo.toDoType = toDoType

            
            /* Don't set every model to the same date, or give them the same sub to dos, that'll cause issues lol */
            if(toDo.id == model.id) {
                toDo.startDate = startDate
                toDo.endDate = endDate
                toDo.subToDoItems = subToDoItems.fixedList
            }
            else {
                toDo.startDate = toDo.startDate.setTime(timeDate: startDate)
                toDo.endDate = toDo.endDate.setTime(timeDate: endDate)
                toDo.subToDoItems = subToDoItems.fixedList.recreatedArrayWithoutCompletion
            }
            toDo.repeatHandler = RepeatHandler(handler: repeatHandler)
            
            toDo.autocomplete = autocomplete
            toDo.notificationDates = notificationDates
            toDo.categories = categories
            
            toDo.timeSheduled = timeSheduled
            toDo.dateSheduled = dateSheduled
                        
            /* Set a creation date [unless this is an edit, in which case we don't overwrite it] */
            if(toDo.creationDate == nil) {
                toDo.creationDate = currDate
            }
            
        }
        
        /* If this is a single update make sure our repeat handler knows it */
        if repeatUpdateBehaviour == .singleUpdate {
            model.unlinkFromRepeats()
        }
        
        /* Update our model with the new progress */
        if toDoType != .multiPart {
            model.progress = progress
        }
        
        /* Update the model */
        update()
        return true
    }
    
    func deleteToDo(ID: String, repeatUpdateBehaviour: RepeatUpdateBehaviour) -> Bool {
        
        /* Get a model for our ID */
        let model = dataController.toDoForID(id: ID)
        
        /* If no such model exists, exit */
        if(model == nil) {
            /* XXX: Better error handling */
            print("Failed to get model")
            return false
        }
        
        if(repeatUpdateBehaviour == .cancel) {
            return false
        }
        
        
        /* Handle the repeats as elegently as possible */
        
        /* If we're updating more than one model */
        
        if repeatUpdateBehaviour == .futureUpdate {
            
            /* Delete every model after our model */
            var nextToDo = model!.nextToDo
            
            while(nextToDo != nil) {
                let next = nextToDo!.nextToDo
                nextToDo!.notificationDates = []
                ToDoDataController.shared.viewContext.delete(nextToDo!)
                nextToDo = next
            }
            
            /* Handle the parent. */
            if(model!.parentToDo != nil) {
                
                /* Set a repeat end date so repeated models aren't recreated */
                let parent = model!.parentToDo!
                
                let repeatHandler = parent.repeatHandler
                repeatHandler.repeatEndDate = model!.startDate.addTime(day: -1)
                parent.repeatHandler = RepeatHandler(handler: repeatHandler)

                
                /* Delete the model */
                model!.notificationDates = []
                ToDoDataController.shared.viewContext.delete(model!)
            }
        }
        else if repeatUpdateBehaviour == .allUpdate {
            
            /* Get our parent model */
            let parent = model!.parentToDo!
            
            /* Remove all the repeats for the parent */
            for child in parent.childToDos?.allObjects as? [ToDoModel] ?? [] {
                child.notificationDates = []
                ToDoDataController.shared.viewContext.delete(child)
            }
            
            /* Delete the parent */
            parent.notificationDates = []
            ToDoDataController.shared.viewContext.delete(parent)
            
        }
        else {
            /* Exclude our date from the parents repeat handler */
            if model!.parentToDo != nil {
                let repeatHandler = model!.parentToDo!.repeatHandler
                repeatHandler.excludedDates.append(model!.startDate)
                model!.parentToDo!.repeatHandler = RepeatHandler(handler: repeatHandler)
            }
            
            /* Delete our model */
            model!.notificationDates = []
            ToDoDataController.shared.viewContext.delete(model!)
        }
        update()
        return true
        
    }
    
    private func fixCategories() {
        
        /* If there's nothing selected, select all by default */
        if !showCompleted && !showNotCompleted && showingCategories.count == 0 {
            all = true
            return
        }
        
        /* Otherwise, all is false */
        all = false
        
        /* If we're showing completed and not completed */
        if showCompleted && showNotCompleted {
            
            /* Show all instead, disable everything else */
            all = true
            showCompleted = false
            showNotCompleted = false
            showingCategories = []
            return
        }
    }
    
}
