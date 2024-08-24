//
//  ToDoModelArrayExtensions.swift
//  LifeLog
//
//  Created by Douglas Inglis on 08/05/2023.
//

import Foundation
import SwiftUI
import CoreData

extension [ToDoModel] {
    
    var sortedToDo: [ToDoModel] {
        return self.sorted(by: {$0.title < $1.title})
    }
    
    var sortedTimeline: [ToDoModel] {
        return self.sorted(by: {
            if $0.endDate == $1.endDate {
                return $0.startDate < $1.startDate
            }
            return $0.endDate < $1.endDate
        })
    }
    
    var dateScheduled: [ToDoModel] {
        
        /* Filter the dateScheduled property */
        return self.filter {
            $0.dateSheduled
        }
    }
    
    var notDateScheduled: [ToDoModel] {
        
        /* Filter the !dateScheduled property */
        return self.filter {
            !$0.dateSheduled
        }
    }
    
    
    var timeScheduled: [ToDoModel] {
        
        /* Filter the timeSheduled property */
        return self.filter {
            $0.timeSheduled
        }
    }
    
    var hasCompleted: [ToDoModel] {
        /* Filter the isCompleted property */
        return self.filter {
            $0.isCompleted
        }

    }
    
    var hasNotCompleted: [ToDoModel] {
        /* Filter the !isCompleted property */
        return self.filter {
            !$0.isCompleted
        }

    }
    
    var notTimeScheduled: [ToDoModel] {
        
        /* Filter the !timeSheduled property */
        return self.filter {
            !$0.timeSheduled
        }
    }
    
    var doesRepeat: [ToDoModel] {
        
        /* Filter the doesRepeat property */
        return self.filter {
            $0.repeatHandler.doesRepeat
        }
    }
    
    var doesNotRepeat: [ToDoModel] {
        
        /* Filter the doesRepeat property */
        return self.filter {
            !($0.repeatHandler.doesRepeat)
        }
    }
    
    var isParentless: [ToDoModel] {
        
        /* Filter the parentToDo property */
        return self.filter {
            $0.parentToDo == nil
        }
    }
    
    func hasPassed(currDate: Date) -> [ToDoModel]  {
        
        /* If the event has happened before the current date */
        return self.filter {
            $0.endDate < currDate
        }
    }
    
    func hasNotPassed(currDate: Date) -> [ToDoModel] {
        
        /* If the event is happening after the current date */
        return self.filter {
            $0.startDate > currDate
        }
    }
    
    func wasCreatedBeforeNow(currDate: Date) -> [ToDoModel] {
        
        /* Creation Date before now, or today */
        return self.filter {
            $0.creationDate! <= currDate || $0.creationDate!.doDatesShareADay(date: currDate)
        }
    }
    
    
    func isToday(currDate: Date) -> [ToDoModel] {
        
        /* Creation Date is today */
        return self.filter {
            $0.startDate.doDatesShareADay(date: currDate)
        }
    }
    
    func isNow(currDate: Date) -> [ToDoModel] {
        
        /* Either not completed, or completed today or after today */
        return self.filter {
            $0.startDate <= currDate && $0.endDate >= currDate
        }
    }
    
    
    func widgetItems(numPieces: Int = 3, currDate: Date = Date()) -> [ToDoModel] {
        var retVal: [ToDoModel] = []
        
        /* Get the items from earlier, right now and later on */
        var earlier = self.hasPassed(currDate: currDate).sorted(by: {$0.endDate < $1.endDate})
        let now = self.isNow(currDate: currDate)
        var later = self.hasNotPassed(currDate: currDate).sorted(by: {$0.startDate < $1.startDate})
        
        /* All events from right now are to be added */
        retVal.append(contentsOf: now)
        
        /* Start from a later event */
        var flipFlop = true
        
        /* while we're under the requested number of pieces, and there's pieces left to add */
        while retVal.count < numPieces && (earlier.count > 0 || later.count > 0) {
            
            /* If we're getting earlier events */
            if !flipFlop {
                
                /* Get the latest earlier item */
                let item = earlier.popLast()
                
                /* If there's no item, then flip back to the later list */
                if item == nil {
                    flipFlop.toggle()
                    continue
                }
                
                /* Insert the item at the start of our list */
                retVal.insert(item!, at: 0)
                
                /* Flip back to the later list */
                flipFlop.toggle()
                continue
            }
            
            /* If the later list is empty switch back to the earlier list */
            if later.count == 0 {
                flipFlop.toggle()
                continue
            }
            
            /* Insert the earliest item having later at the end of the array */
            retVal.insert(later.removeFirst(), at: retVal.count)
            
            /* Flip back to the earlier list */
            flipFlop.toggle()
        }
        
        retVal = retVal.sortedTimeline
        
        /* If we have less or equal to numPieces events, return the array */
        if(retVal.count <= numPieces) {
            return retVal
        }
        
        /* If we have more than numPieces events [happens if there's more than numPieces events right now], then trim our list */
        return Array(retVal[..<numPieces])
    }
    
    
    
    func wasCompletedAfterNow(currDate: Date) -> [ToDoModel] {
        
        /* Either not completed, or completed today or after today */
        return self.filter {
            !$0.isCompleted || $0.completedDate >= currDate || $0.completedDate.doDatesShareADay(date: currDate)
        }
    }
    
    func matchingID(id: String) -> ToDoModel? {
        
        /* Find item with matching ID */
        let item = self.filter {
            $0.ID == id
        }
        
        /* If an item exists return it */
        if(item.count == 1) {
            return item[0]
        }
        
        /* Else return nil */
        return nil
    }
    
    func repeatsToday(currDate: Date) -> [ToDoModel] {
        
        /* Filter the doesRepeatToday property */
        return self.filter {
            $0.repeatHandler.doesRepeatToday(currDate: currDate)
        }
    }
    
    func hasCategory(category: Category) -> [ToDoModel] {
        /* Check if categories contains category */
        return self.filter {
            $0.categories.contains(category)
        }
    }
    
    
}
