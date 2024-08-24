//
//  Preferences.swift
//  LifeLog
//
//  Created by Douglas Inglis on 23/05/2023.
//

import Foundation


class Preferences: ObservableObject {
    
    /* Shared so that the variables are linked everywhere */
    static var shared = Preferences()
    
    /* If we're drag + dropping, this field is populated */
    @Published var draggedModel: ToDoModel? = nil
    
    /* If we're dragging, this is set to true */
    @Published var isDragging: Bool = false
    
    /* The mode for the homescreen */
    @Published var homeScreenMode: HomeScreenMode = .normal
    
    /* If the app has been opened before */
    @Published var hasBeenOpened: Bool = UserDefaults.standard.bool(forKey: "hasBeenOpened")
    
    var isProUser: Bool {
        return PurchasePreferences.shared.isProUser
    }
    
    var shouldRequestReview: Bool {
        get {
            let dateRequest = Date(timeIntervalSince1970: UserDefaults.standard.double(forKey: "reviewDate"))
            if dateRequest.timeIntervalSince1970 == 0 || dateRequest.addTime(day: 122) < Date() {
                
                UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: "reviewDate")
                return true
            }
            return false
        }
    }
    
    
    /* We store our time presets here, stored in userdefaults as JSON */
    var timePresets: [Timedelta] {
        get {
            /* Get the JSON representation */
            let jsonRepresentation = UserDefaults.standard.array(forKey: "timePresetIDs") as? [String] ?? []
            
            /* Convert to an object */
            return jsonRepresentation.map {Timedelta(codedString: $0)}
        }
        set {
            /* Get the JSON representation */
            let jsonRepresentation = newValue.map {$0.encodeToString()}
            
            /* Assign it to user defaults */
            UserDefaults.standard.set(jsonRepresentation, forKey: "timePresetIDs")
        }
    }
    
    func getDraggedModelTimeDelta() -> Int {
        
        /* If there's no model, there's no timedelta */
        if draggedModel == nil {
            return 0
        }
        
        /* timescheduled models already have a time delta */
        if draggedModel!.timeSheduled {
            return draggedModel!.startDate.timeDeltaInMinutes(date: draggedModel!.endDate)
        }
        
        /* Default to ten minutes */
        return 10
    }

    
    
    init() {
        
        /* Intialise soem fields on first start */
        if !hasBeenOpened {
            timePresets = [1, 15, 60, 90, 120].map { Timedelta(timeDelta: $0) }
        }
        
        /* Now that first start has happened, set that! */
        hasBeenOpened = true
        UserDefaults.standard.set(true, forKey: "hasBeenOpened")
    }
}
