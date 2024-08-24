//
//  ToDoDataController.swift
//  LifeLog
//
//  Created by Douglas Inglis on 22/05/2023.
//

import Foundation
import SwiftUI
import CoreData
import WidgetKit

class ToDoDataController: ObservableObject {
    static var shared: ToDoDataController = ToDoDataController()
    private var persistentContainer: NSPersistentCloudKitContainer
    
    @Published var timeBasedItems: [ToDoModel] = []
    @Published var toDoItems: [ToDoModel] = []

    @Published var categoryList: [Category] = []

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    @Published var currDate: Date = Date() {
        didSet {
            
            /* Refresh our arrays when the date changes */
            refresh()
        }
    }
    
    
    private var updateQueue: OperationQueue
    
    @objc
    func iCloudSyncUpdate(notification: NSNotification) {
        /* Get user event data */
        guard let event = notification.userInfo?[NSPersistentCloudKitContainer.eventNotificationUserInfoKey] as? NSPersistentCloudKitContainer.Event else {
            return
        }
        
        /* If this was the end of an event, the event was successful and it was an import */
        if event.succeeded && event.endDate != nil && event.type == .import {
            
            /* Add a refresh operation to the queue */
            updateQueue.addOperation {
                DispatchQueue.main.async {
                    self.sortNotifications()
                    self.cleanUp(cleanCategories: false)
                    self.refresh()
                }
            }
        }
    }
        
    init() {
        
        /* Setup a Mutex queue to allow one update at once when CloudKit updates */
        updateQueue = OperationQueue()
        updateQueue.maxConcurrentOperationCount = 1
        
        /* Get the permenant container group */
        #if DEBUG
        
        /* Development builds use a different model to avoid cross contamination */
         let containerGroup = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.synackuk.ToDoToday")!.appendingPathComponent("model_DEV.sqlite")
        #else
        
        /* Release builds just use the standard model */
        let containerGroup = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.synackuk.ToDoToday")!.appendingPathComponent("model.sqlite")

        #endif
        
        /* Setup our data container */
        persistentContainer = NSPersistentCloudKitContainer(name: "ToDoModel")
        

        /* Setup a description linked to our permenant container */
        let description = NSPersistentStoreDescription(url: containerGroup)
                
        /* Link ourselves to the cloudkit instance */
        description.cloudKitContainerOptions = NSPersistentCloudKitContainerOptions(containerIdentifier: "iCloud.com.synackuk.ToDoToday")
                        
        /* Set our descriptions */
        persistentContainer.persistentStoreDescriptions = [description]
                
        /* Load our stores */
        persistentContainer.loadPersistentStores { _, error in
            if let error = error as NSError? {
                /* XXX: Fix the error handling */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        #if DEBUG
        
        /* If we're a debug build initalise the cloudkit schema */
        try? persistentContainer.initializeCloudKitSchema()
        #endif
        
        /* Setup merging and the merge policy */
        persistentContainer.viewContext.automaticallyMergesChangesFromParent = true
        persistentContainer.viewContext.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        
        /* Setup a notification for our container */
        NotificationCenter.default.addObserver(self, selector: #selector(iCloudSyncUpdate), name: NSPersistentCloudKitContainer.eventChangedNotification, object: nil)
        
        performReset()
        
        /* Refresh the arrays to get current items */
        refresh()
    }
    func update() {
        
        /* Save new items and refresh our arrays */
        save()
        refresh()
    }
    
    func refresh() {
        
        /* Predicate for todays non-repeating items */
        let todaysItemsPredicate = NSPredicate(format: "dateSheduled == YES AND backingStartDate >= %@ AND backingEndDate <= %@", currDate.startOfDay as CVarArg, currDate.startOfDay.addTime(day: 1) as CVarArg)
        
        /* Get todays items, along with todays repeats */
        let todaysItems = fetchToDoModels(predicate: todaysItemsPredicate).doesNotRepeat + getTodaysRepeats()
        
        /* Predicate for todays etheral ToDo items */
        let etheralToDosPredicate = NSPredicate(format: "dateSheduled == NO AND backingCreationDate <= %@ AND (backingProgress != backingCompletedUnits OR backingCompletedDate >= %@)", currDate.startOfDay.addTime(day: 1) as CVarArg, currDate.startOfDay as CVarArg)
        
        /* Get uncompleted, etheral todo items [or those that have been completed the same day] */
        let etheralToDos = fetchToDoModels(predicate: etheralToDosPredicate)
        
        /* To do items are made up of etheral to do items and scheduled items without a time attached, sorted by title */
        toDoItems = (etheralToDos + todaysItems.notTimeScheduled).sortedToDo
        
        /* time based items are made up of todays timescheduled items, sorted by end date */
        timeBasedItems = (todaysItems.timeScheduled).sortedTimeline

    }
    
    private func fetchCategories(predicate: NSPredicate? = nil) -> [Category] {
        var retVal: [Category] = []
        
        /* Create a fetch request for the categories */
        let categoryFetch = NSFetchRequest<Category>(entityName: "Category")
        categoryFetch.predicate = predicate
        do {
            
            /* Attempt to fulfill the fetch request */
            retVal = try viewContext.fetch(categoryFetch)
        }
        catch {
            
            /* XXX: Fix error handling */
            print("DEBUG: Some error occured while fetching")
        }
        return retVal
    }
    
    private func fetchToDoModels(predicate: NSPredicate? = nil) -> [ToDoModel] {
        var retVal: [ToDoModel] = []
        
        /* Create a fetch request for the ToDoModel */
        let toDoModelFetch = NSFetchRequest<ToDoModel>(entityName: "ToDoModel")
        toDoModelFetch.predicate = predicate
        do {
            
            /* Attempt to fulfill the fetch request */
            retVal = try viewContext.fetch(toDoModelFetch)
        }
        catch {
            
            /* XXX: Fix error handling */
            print("DEBUG: Some error occured while fetching")
        }
        return retVal

    }
    
    func save() {
        
        /* Check if we have made changes to the view context, and if not, return. */
        viewContext.performAndWait {
            if !viewContext.hasChanges {
                return
            }
            
            
            do {
                
                /* Try to save the viewcontext */
                try viewContext.save()
            }
            catch {
                
                /* XXX: Fix error handling */
                print("Error")
            }
        }
        /* Update our widgets */
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    func toDoForID(id: String) -> ToDoModel? {
        let predicate = NSPredicate(format: "id == %@", id)
        let models = fetchToDoModels(predicate: predicate)
        return models.count == 1 ? models[0] : nil
    }
    
    private func getTodaysRepeats() -> [ToDoModel] {
        
        /* Setup the output array, that adds todays repeats to the list of repeats */
        var outputArray: [ToDoModel] = []
        
        /* Get parentless items created before now */
        let parentlessPredicate = NSPredicate(format: "isChild == false AND backingStartDate <= %@", currDate.startOfDay.addTime(day:1) as CVarArg)
        let parentlessItems = fetchToDoModels(predicate: parentlessPredicate)
        
        /* Get all of the to do list items which repeat today and have no parents (therefore being the parent themselves */

        let repeats = parentlessItems.doesRepeat
        let repeatsToday = repeats.repeatsToday(currDate: currDate)
        let repeatParents = repeatsToday
        
        /* Loop through all the parents */
        for parent in repeatParents {
            /* Get all of the children for a given parent */
            let childArray = parent.childToDos?.allObjects as? [ToDoModel] ?? []
            
            /* If a child exists for today, use that child and move on */
            let child = childArray.isToday(currDate: currDate)
            if(child.count == 1) {
                outputArray.append(child[0])
                continue
            }
                        
            /* If no suitable child exists */
            
            var previousChildToUs = parent
            
            /* Loop through all the children in order, finding the most recent one that starts before today, unless we're the latest; in which case we use the parent */
            while(previousChildToUs.nextToDo != nil) {
                previousChildToUs = previousChildToUs.nextToDo!
                if(previousChildToUs.startDate > currDate) {
                    previousChildToUs = previousChildToUs.prevToDo!
                    break
                }
            }
            
            /* If we're looking at the end of the queue, take the parent */
            if previousChildToUs.nextToDo == nil {
                previousChildToUs = parent
            }
            
            /* Create a new model */
            let newModel = ToDoModel(model: previousChildToUs)
            newModel.nextToDo = previousChildToUs.nextToDo
            previousChildToUs.nextToDo = newModel
            newModel.parentToDo = parent
            newModel.startDate = newModel.startDate.setDay(dayDate: currDate)
            newModel.endDate = newModel.endDate.setDay(dayDate: currDate)
            newModel.isChild = true
            
            /* If we're the first child, copy the parents progress in case we've been changed to repeat */
            newModel.decimalProgress = childArray.count == 0 ? parent.decimalProgress : 0
            
            /* Write over the ID, setting it to the parent ID plus the start date - allows iCloud to sync them properly */
            newModel.ID = parent.ID + newModel.startDate.formatDate(formatString: "dd/MM/yyyy")
                        
            /* Put that model in the relevent places */
            outputArray.append(newModel)
        }
        return outputArray
    }
    
    func performReset() {
        /* Function that's ran in background refreshes and at app init. */
                
        
        /* First, make sure there's a repeat in the future */
        createFutureRepeats()
        
        
        /* Now, sort notifications */
        sortNotifications()
        
        
        /* Finally, cleanup duplicate items */
        cleanUp()

        
        /* And save! */
        save()
        
    }
    
    private func cleanUp(cleanCategories:Bool = true) {
                
        /* Get toDo items */
        var toDoItems: [ToDoModel] = fetchToDoModels()
        
        /* Delete duplicate ones */
        for item in toDoItems {

            /* Get all the models with a certain ID */
            let predicate = NSPredicate(format: "id == %@", item.ID)
            let models = fetchToDoModels(predicate: predicate)
            
            /* If the count of models with that ID > 1, delete the model */
            if models.count > 1 {
                viewContext.delete(item)
            }

        }
        
        /* Delete children that should no longer exist */
        toDoItems = fetchToDoModels()
        for item in toDoItems {
            if item.parentToDo != nil {
                /* If the parent doesn't repeat today, delete the child */
                if !item.parentToDo!.repeatHandler.doesRepeatToday(currDate: item.startDate) {
                    viewContext.delete(item)
                }
            }
        }
        
        if !cleanCategories {
            return
        }
        
        /* Get categories */
        let categories: [Category] = fetchCategories()
                
        /* Filter for Categories with no name */
        let badCategories = categories.filter({$0.title.trimmingCharacters(in: .whitespacesAndNewlines) == ""})
        
        /* Delete them */
        for badCategory in badCategories {
            viewContext.delete(badCategory)
        }
    }
    
    private func sortNotifications() {
        
        #if !os(watchOS)
        /* Clear out the notifications and start again */
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        #endif
        
        /* Predicate for all items with notifications */
        let notificationsPredicate = NSPredicate(format: "backingNotificationDates != %@ AND backingStartDate >= %@", [] as [String] as CVarArg, Date() as CVarArg)
        
        /* Get a list of all items with notifications */
        let notificationList = fetchToDoModels(predicate: notificationsPredicate)
        
        /* Clear out notifications and reset them - aids support with iCloud. */
        
        for model in notificationList {
            let notifications = model.notificationDates
            
            /* Clears out notifications */
            model.notificationDates = []
            
            /* Re-add them */
            model.notificationDates = notifications
        }
        
    }
    
    private func createFutureRepeats() {
        
        /* Identify items that we need to create repeats for */
        
        /* Get parentless items created before now */
        let parentlessPredicate = NSPredicate(format: "isChild == false AND backingStartDate <= %@", currDate.startOfDay.addTime(day:1) as CVarArg)
        let parentlessItems = fetchToDoModels(predicate: parentlessPredicate)
        
        /* Get all of the to do list items which repeat today and have no parents (therefore being the parent themselves */

        let repeats = parentlessItems.doesRepeat
        
        /* Loop through all the parents */
        for parent in repeats {
            var lastChild = parent
            
            /* Get the latest child to the parent */
            while lastChild.nextToDo != nil {
                lastChild = lastChild.nextToDo!
            }
            
            /* If the item is after today, we can stop here */
            if lastChild.startDate >= Date().startOfDay {
                continue
            }
            
            /* Otherwise, create the item that is after today, unless we're after the repeat end date */
            var newDay = Date()
            while newDay <= parent.repeatHandler.repeatEndDate && !parent.repeatHandler.doesRepeatToday(currDate: newDay) {
                
                /* If the parent doesn't repeat on this date, move onto tomorrow */
                newDay = newDay.addTime(day: 1)
            }
            
            if !parent.repeatHandler.doesRepeatToday(currDate: newDay) {
                parent.repeatHandler = RepeatHandler(handler: parent.repeatHandler)
                continue
            }
                        
            /* Create a new model */
            let newModel = ToDoModel(model: parent)
            newModel.nextToDo = lastChild.nextToDo
            lastChild.nextToDo = newModel
            newModel.parentToDo = parent
            newModel.startDate = newModel.startDate.setDay(dayDate: newDay)
            newModel.endDate = newModel.endDate.setDay(dayDate: newDay)
            newModel.isChild = true
            
            /* Get all of the children for a given parent */
            let childArray = parent.childToDos?.allObjects as? [ToDoModel] ?? []
            
            /* If we're the first child, copy the parents progress in case we've been changed to repeat */
            newModel.decimalProgress = childArray.count == 0 ? parent.decimalProgress : 0
            
            /* Write over the ID, setting it to the parent ID plus the start date - allows iCloud to sync them properly */
            newModel.ID = parent.ID + newModel.startDate.formatDate(formatString: "dd/MM/yyyy")

        }
    }
    
}
