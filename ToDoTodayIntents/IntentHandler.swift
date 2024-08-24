//
//  IntentHandler.swift
//  ToDoTodayIntents
//
//  Created by Douglas Inglis on 15/06/2023.
//

import Intents

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        /* We only have one shortcut exposed, so we only need to deal with one handler */
        return CreateTimedToDoIntentHandler()
    }
    
}
final class CreateTimedToDoIntentHandler: NSObject, CreateUntimedToDoIntentHandling {
    func resolveTitle(for intent: CreateUntimedToDoIntent, with completion: @escaping (INStringResolutionResult) -> Void) {
        /* Resolve the to-dos title */
        guard let Title = intent.Title else {
            completion(.confirmationRequired(with: intent.Title))
            return
        }

        completion(.success(with: Title))
    }
    
    func resolveToDoType(for intent: CreateUntimedToDoIntent, with completion: @escaping (IntentToDoTypeResolutionResult) -> Void) {
        /* Resolve the to-dos type */

        if intent.ToDoType == .unknown {
            completion(.needsValue())
            return
        }
        completion(.success(with: intent.ToDoType))
        
    }
        
    func resolveMultiPartItems(for intent: CreateUntimedToDoIntent, with completion: @escaping ([INStringResolutionResult]) -> Void) {
        /* Resolve the multi part items */
        guard let multiPartItems = intent.multiPartItems else {
            if intent.ToDoType != .multiPartItem {
                completion([.success(with: "")])
                return
            }
            completion([.confirmationRequired(with: "Hello")])
            return
        }

        completion(multiPartItems.map {INStringResolutionResult.success(with: $0)})
    }
        
    func resolveCompletedUnits(for intent: CreateUntimedToDoIntent, with completion: @escaping (CreateUntimedToDoCompletedUnitsResolutionResult) -> Void) {
        /* Resolve the completed units */
        guard let completedUnits = intent.completedUnits else {
            if intent.ToDoType != .goalItem {
                completion(.success(with:1))
                return
            }
            completion(.needsValue())
            return

        }

        completion(.success(with: completedUnits.intValue))
    }
        
    func resolveScheduledItem(for intent: CreateUntimedToDoIntent, with completion: @escaping (INBooleanResolutionResult) -> Void) {
        /* Resolve the scheduled item */
        guard let ScheduledItem = intent.scheduledItem  else {
            completion(.confirmationRequired(with: intent.scheduledItem?.boolValue))
            return
        }


        completion(.success(with: ScheduledItem.boolValue))

    }
    
    func resolveStartDate(for intent: CreateUntimedToDoIntent, with completion: @escaping (INDateComponentsResolutionResult) -> Void) {
        /* Resolve the start date */
        guard let startDate = intent.startDate  else {
            completion(.confirmationRequired(with: intent.startDate))
            return
        }


        completion(.success(with: startDate))

    }
        
    func resolveDuration(for intent: CreateUntimedToDoIntent, with completion: @escaping (INTimeIntervalResolutionResult) -> Void) {
        /* Resolve the duration */
        guard let duration = intent.duration  else {
            completion(.confirmationRequired(with: intent.duration!.doubleValue))
            return
        }


        completion(.success(with: duration.doubleValue))

    }

    func handle(intent: CreateUntimedToDoIntent, completion: @escaping (CreateUntimedToDoIntentResponse) -> Void) {
        /* Get the title and whether the item is scheduled */
        guard let Title = intent.Title else {
            completion(CreateUntimedToDoIntentResponse(code: .failure, userActivity: nil))
            return
        }
        guard let scheduled = intent.scheduledItem?.boolValue else {
            completion(CreateUntimedToDoIntentResponse(code: .failure, userActivity: nil))
            return
        }
        
        /* Resolve other values for the model */
        let rawVal = intent.ToDoType.rawValue == 3 ? 0 : intent.ToDoType.rawValue
        let toDoType = ToDoType(rawValue: Int32(rawVal))!
        let multiPartItems = (intent.multiPartItems ?? []).map {SubToDoItem(title: $0)}
        let completedUnits = intent.completedUnits?.intValue ?? 1
        let startDate = intent.startDate != nil ? Calendar.current.date(from: intent.startDate!)! : Date()
        let endDate = startDate.addTime(second: intent.duration?.intValue ?? 0)
        
        /* Create the model and save it */
        let model = ToDoModel(ctx: ToDoDataController.shared.viewContext, title: Title, completedUnits: completedUnits, startDate: startDate, endDate: endDate, timeSheduled: scheduled, dateSheduled: scheduled, toDoType: toDoType, subToDoItems: multiPartItems)
        model.creationDate = Date()
        ToDoDataController.shared.save()
        completion(CreateUntimedToDoIntentResponse(code: .success, userActivity: nil))
        
    }

    
}
