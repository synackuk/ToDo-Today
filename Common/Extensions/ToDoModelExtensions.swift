//
//  ToDoModelExtensions.swift
//  LifeLog
//
//  Created by Douglas Inglis on 07/05/2023.
//

import Foundation
import SwiftUI
import CoreData

extension ToDoModel {
    
    
    /* Pass through our backing variables, so that we don't need to deal with optional ones at every occasion */
    var completedDate: Date {
        get {
            return backingCompletedDate ?? Date()
        }
        set {
            backingCompletedDate = newValue
        }
    }
    
    
    var notificationDates: [Timedelta] {
        get {
            let notificationDatesUnwrapped = backingNotificationDates ?? []
            return notificationDatesUnwrapped.map {Timedelta(codedString: $0)}
        }
        set {
            /* No notifications on watchOS */
            #if !os(watchOS)
            
            /* Remove all current notifications */
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: notificationDates.map({self.ID + $0.encodeToString()}))
            
            
            for dateBefore in newValue {

                /* Create a notification template */
                let notificationContent = UNMutableNotificationContent()
                notificationContent.title = self.title
                notificationContent.subtitle = self.notes
                notificationContent.sound = UNNotificationSound.default

                /* Get authorisation if we don't have it yet */
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                }
                                
                /* If we're not timescheduled set our start date to the start of day */
                var startDate = self.startDate
                if !self.timeSheduled {
                    startDate = startDate.startOfDay
                }
                
                /* Calculate date difference */
                let notificationDate = startDate.addTime(day: -dateBefore.days, hour: -dateBefore.hours, minute: -dateBefore.minutes)
                
                /* Don't set notifications in the past */
                if notificationDate < Date() {
                    continue
                }
                
                
                /* Get date components */
                let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: notificationDate)
                
                /* Setup notification */
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                let id = self.ID + dateBefore.encodeToString()
                let request = UNNotificationRequest(identifier: id, content: notificationContent, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
            #endif
            backingNotificationDates = newValue.map{$0.encodeToString()}
        }
    }
    
    /* Pass through our backing variables, so that we don't need to deal with optional ones at every occasion */
    var completedUnits: Int {
        get {
            return Int(backingCompletedUnits)
        }
        set {
            backingCompletedUnits = Int64(newValue)
        }
    }
    
    /* Pass through our backing variables, so that we don't need to deal with optional ones at every occasion */
    var creationDate: Date? {
        get {
            return backingCreationDate
        }
        set {
            backingCreationDate = newValue
        }
    }
    
    /* Pass through our backing variables, so that we don't need to deal with optional ones at every occasion */
    var startDate: Date {
        get {
            return backingStartDate?.setTime(second: 0) ?? Date().setTime(second: 0)
        }
        set {
            backingStartDate = newValue
        }
    }
    
    /* Pass through our backing variables, so that we don't need to deal with optional ones at every occasion */
    var endDate: Date {
        get {
            return backingEndDate?.setTime(second: 0) ?? Date().setTime(second: 0)
        }
        set {
            backingEndDate = newValue
        }
    }
    
    var categories: [Category] {
        get {
            return backingCategories?.allObjects as? [Category] ?? []
        }
        set {
            backingCategories = NSSet(array: newValue)
        }
    }
    
    /* Pass through our backing variables, so that we don't need to deal with optional ones at every occasion */
    var icon: String {
        get {
            return backingIcon ?? "xmark.circle.fill"
        }
        set {
            backingIcon = newValue
        }
    }
    
    /* Pass through our backing variables, so that we don't need to deal with optional ones at every occasion */
    var ID: String {
        get {
            return id ?? ""
        }
        set {
            id = newValue
        }
    }
    
    /* Pass through our backing variables, so that we don't need to deal with optional ones at every occasion */
    var notes: String {
        get {
            return backingNotes ?? ""
        }
        set {
            backingNotes = newValue
        }
    }
    
    /* Pass through our backing variables, so that we don't need to deal with optional ones at every occasion */
    var title: String {
        get {
            return backingTitle ?? ""
        }
        set {
            backingTitle = newValue
        }
    }
    
    /* Pass through our backing variables, so that we don't need to deal with optional ones at every occasion */
    var progressStep: Int {
        get {
            return Int(backingProgressStep)
        }
        set {
            backingProgressStep = Int64(newValue)
        }
    }
    
    /* Pass through our backing variables, so that we don't need to deal with optional ones at every occasion */
    var subToDoItems: [SubToDoItem] {
        get {
            /* Get the JSON representation */
            let jsonRepresentation = backingSubToDoItems ?? []
            
            /* Convert to an object */
            return jsonRepresentation.map {SubToDoItem(codedString: $0)}
        }
        set {
            /* Get the JSON representation */
            let jsonRepresentation = newValue.map {$0.encodeToString()}
            
            /* Assign it to user defaults */
            backingSubToDoItems = jsonRepresentation
            
            if toDoType == .multiPart {
                completedUnits = newValue.count
                progress = newValue.filter {$0.completed}.count
            }
            
        }
    }
    
    /* Pass through our backing variables, so that we don't need to deal with optional ones at every occasion */
    var decimalProgress: Decimal {
        get {
            
            /* Single part items have completed units = 1*/
            let decimalProgress = Decimal(progress)/Decimal(completedUnits)
            
            /* If we're autocompleting... */
            if(autocomplete && timeSheduled && decimalProgress < 1) {
                
                /* Return comlete if end date before current date */
                if(endDate < Date()) {
                    return 1
                }
            }
            /* Calculate the progress as a decimal */
            return decimalProgress
        }
        
        set {
            /* Allows us to use decimalProgress as a binding property */
            
            /* Simple rearranging to work out the correct progress value */
            progress = NSDecimalNumber(decimal: newValue * Decimal(completedUnits)).intValue
        }
    }
    
    /* Pass through our backing variables, so that we don't need to deal with optional ones at every occasion */
    var goal: String {
        if toDoType != .multiPart {
            return ""
        }
                
        for item in subToDoItems {
           if !(item.completed) {
               return item.title
           }
        }
        
        return subToDoItems.last?.title ?? ""
    }
    
    var toDoColour: Color {
        get {
            
            /* We store the colour as a JSON object because Colours aren't supported by CoreData models */
            let decoder = JSONDecoder()
            if(toDoBackingColour == nil) {
                return .yellow
                
            }
            
            var components = [0.0, 0.0, 0.0]
            do {
                
                /* Try decoding our colour */
                components = try decoder.decode([Double].self, from: toDoBackingColour!.data(using: .utf8)!)
            }
            catch {}
            
            /* Create a colour from components */
            return Color(red:components[0], green:components[1], blue:components[2], opacity: components[3])
        }
        set {
            
            /* Encode out colour as JSON */
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try! encoder.encode(UIColor(newValue).cgColor.components)
            toDoBackingColour = String(data: data, encoding: .utf8)!
        }
    }
    
    var completionText: String {
        
        /* Set based on the type of to do this is */
        switch(toDoType) {
        case .singlePart:
            return ""
        case .multiPart:
            return  "\(progress)/\(completedUnits)"
        case .goal:
            return  "\(progress)/\(completedUnits)"
        }
    }
    
    var progress: Int {
        
        /* Set based on the type of to do this is */
        get {
            return Int(backingProgress)
        }
        set {
            backingProgress = Int64(newValue)
        }
    }
    
    
    var timeStamp: String {
        
        /* No timestamp for non timescheduled items */
        if(!timeSheduled) {
            return ""
        }
        
        if(startDate.doDatesShareATime(date: endDate)) {
            return "\(startDate.formatDate(formatString: "HH:mm"))"
        }
        
        /* Simply format the start time - end time */
        return "\(startDate.formatDate(formatString: "HH:mm")) - \(endDate.formatDate(formatString: "HH:mm"))"
    }
    
    /* Pass through our backing variables, so that we don't need to deal with optional ones at every occasion */
    
    var toDoType: ToDoType {
        get {
            return ToDoType(rawValue: backingToDoType) ?? ToDoType.singlePart
        }
        set {
            backingToDoType = newValue.rawValue
        }
    }
    
    
    var isCompleted: Bool  {
        /* We're done if the progress is at least one */
        return decimalProgress >= 1
    }
    
    /* Pass through our backing variables, so that we don't need to deal with optional ones at every occasion */
    var repeatHandler: RepeatHandler {
        get {
            return RepeatHandler(codedString: backingRepeatHandler ?? "")
        }
        set {
            backingRepeatHandler = newValue.encodeToString()
        }
    }
    
    
    func makeProgress() {
        
        switch(toDoType) {
        case .singlePart:
            /* If we're a single part to do then set progress to one, or if we've alreadt finished, reset it to 0 */
            progress = (progress != 1) ? 1 : 0
            break
        case .multiPart:
            /* If we're a multipart item tick off the next item in the list */
            if !isCompleted {
                let items = subToDoItems
                for item in items {
                    if !item.completed {
                        item.completed = true
                        subToDoItems = items
                        break
                    }
                }
            }
            else {
                let items = subToDoItems
                /* If they're all ticked off, reset the list */
                for item in items {
                    item.completed = false
                }
                subToDoItems = items
            }
            break
        case .goal:
            
            /* If this item is a goal, just add the progress step */
            progress += progressStep
            break
        }
        if isCompleted {
            completedDate = ToDoDataController.shared.currDate
        }
    }
    
    func unlinkFromRepeats() {
        
        /* Link the previous item to the next item */
        prevToDo?.nextToDo = nextToDo
        
        /* Disassociate ourself from the previous and next item */
        prevToDo = nil
        nextToDo = nil
        
        /* Add our date to the parents excluded list, and get rid of our parent */
        let newParentHandler = parentToDo?.repeatHandler
        newParentHandler?.excludedDates.append(startDate)
        parentToDo?.repeatHandler = RepeatHandler(handler: newParentHandler ?? RepeatHandler(excludedDates: [startDate]))
        parentToDo = nil
        
        /* Set the repeat class to none */
        let newHandler = repeatHandler
        newHandler.repeatClass = .none
        repeatHandler = RepeatHandler(handler: newHandler)
    }
    
    /* Init with a full suite of default parameters - works to make sure parameters are never 'nil' unless they're supposed to be */
    convenience init(ctx: NSManagedObjectContext, id:String = UUID().uuidString, title: String = "", icon: String = "questionmark.circle.fill", progress: Int = 0, completedUnits: Int = 1, toDoColour: Color = .yellow, startDate: Date = Date(), endDate: Date = Date(), completedDate: Date = .distantPast, progressStep: Int = 1, timeSheduled: Bool = false, dateSheduled: Bool = false, locked: Bool = false, repeatHandler: RepeatHandler? = nil, parentToDo: ToDoModel? = nil, nextToDo: ToDoModel? = nil, autocomplete: Bool = false, notificationDates: [Timedelta] = [], notes: String = "", categories: [Category] = [], toDoType: ToDoType = ToDoType.singlePart, subToDoItems: [SubToDoItem] = []) {
        
        /* Initialise with our context */
        self.init(context: ctx)
        
        /* Set all parameters */
        self.ID = id
        self.title = title
        self.icon = icon
        self.progress = progress
        self.completedUnits = toDoType == .singlePart ? 1 : completedUnits
        self.toDoColour = toDoColour
        self.startDate = startDate
        self.endDate = endDate
        self.completedDate = completedDate
        self.progressStep = progressStep
        self.locked = locked
        self.timeSheduled = timeSheduled
        self.dateSheduled = dateSheduled
        
        self.repeatHandler = (repeatHandler != nil) ? repeatHandler! : RepeatHandler()
        self.parentToDo = parentToDo
        self.nextToDo = nextToDo
        self.autocomplete = autocomplete
        self.notes = notes
        self.categories = categories
        self.notificationDates = notificationDates
        self.toDoType = toDoType
        self.subToDoItems = subToDoItems
        self.isChild = false
        self.creationDate = Date()
    }
    
    /* Init from an older model, useful innit */
    convenience init(model: ToDoModel) {
        self.init(ctx: model.managedObjectContext!, title: model.title , icon: model.icon , completedUnits: model.completedUnits, toDoColour: model.toDoColour, startDate: model.startDate , endDate: model.endDate , timeSheduled: model.timeSheduled, dateSheduled: model.dateSheduled, locked: model.locked, repeatHandler: RepeatHandler(handler: model.repeatHandler), parentToDo: model.parentToDo, nextToDo: model.nextToDo, autocomplete: model.autocomplete, notificationDates: model.notificationDates, notes: model.notes, categories: model.categories, toDoType: model.toDoType)
        self.subToDoItems = model.subToDoItems.recreatedArrayWithoutCompletion
    }
    
}
