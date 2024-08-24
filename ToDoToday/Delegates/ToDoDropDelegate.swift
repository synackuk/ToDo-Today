//
//  ToDoDropDelegate.swift
//  LifeLog
//
//  Created by Douglas Inglis on 21/05/2023.
//

import Foundation
import SwiftUI


struct ToDoDropDelegate: DropDelegate {
    @State var isbeingSheduled: Bool = false
    @State var startTime: Date = .distantPast
    @State var timeDelta: Int = 0
    @Binding var isShowing: Bool
    @State private var mainModel: ToDoViewModel = ToDoViewModel.shared
    @State private var preferences: Preferences = Preferences.shared

    
    func dropEntered(info: DropInfo) {
        isShowing = true
        preferences.isDragging = true
    }
    func dropExited(info: DropInfo) {
        isShowing = false
    }
    
    
    
    func performDrop(info: DropInfo) -> Bool {
        
        /* Reset isShowing and isDragging */
        isShowing = false
        preferences.isDragging = false
        
        /* If we don't have a model being dragged, return false */
        if preferences.draggedModel == nil {
            return false
        }
        
        /* Get our model and clear out the draggedModels */
        let model = preferences.draggedModel!
        preferences.draggedModel = nil
        
        
        /* This item's no longer repeating. */
        model.unlinkFromRepeats()

        /* If we're switching dates */
        if startTime != .distantPast {
            
            /* Enable date scheduling and set the new start and end date */
            model.dateSheduled = true
            model.startDate = startTime
            model.endDate = Calendar.current.date(byAdding: .minute, value:timeDelta, to: startTime)!
        }
        
        /* If we're straddling two days, go to the end of the day */
        if !model.startDate.doDatesShareADay(date: model.endDate) {
            model.endDate = model.endDate.endOfDay
        }
        
        /* Set timescheduling */
        model.timeSheduled = isbeingSheduled
                
        /* Reset notifications for new date */
        model.notificationDates = []
        
        
        /* Update the model */
        mainModel.update()
        
        /* Clear the currently dragged model */
        preferences.draggedModel = nil
        return true
    }
    
}
