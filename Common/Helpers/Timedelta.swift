//
//  Timedelta.swift
//  ToDo, Today
//
//  Created by Douglas Inglis on 08/06/2023.
//

import Foundation


struct Timedelta: Codable, Identifiable, Equatable {
    /* The ID For our timedelta */
    var id: UUID = UUID()
    
    /* The timedelta, represented in whole minutes as an integer */
    var time: Int = 0
    
    var days: Int {
        get {
            
            /* Convert time to a double */
            let doubleTime = Double(time)
            
            /* Divide time to get number of days */
            let numDays = doubleTime/(60 * 24)
            
            /* Get number of days as an integer */
            return Int(numDays.rounded(.down))
        }
        
        set {
            /* Get rid of days using modulus */
            time %= (60 * 24)
            
            time += newValue * (60 * 24)
        }
    }
    
    var hours: Int {
        get {
            
            /* Get rid of the days */
            let timeSansDays = time % (60 * 24)
            
            /* Convert to Double */
            let doubleTime = Double(timeSansDays)
            
            /* Get the number of hours */
            let numHours = doubleTime/60
            
            /* Round down */
            return Int(numHours.rounded(.down))

        }
        
        set {
            /* Get the number of days before changing anything*/
            let numDays = days
            
            /* Get rid of days and hours using modulus */
            time %= 60
            
            /* Re-add the lost days */
            time += numDays * (60 * 24)
            
            /* Add the new hours */
            time += newValue * 60
        }
    }
    
    var minutes: Int {
        get {
            /* Minutes are just the time mod 60 */
            return time % 60
        }
        set {
            /* Get rid of the initial minutes */
            let preMins = time % 60
            time -= preMins
            
            /* Add new minutes */
            time += newValue
        }
    }
    
    func timeString(defaultString: String = "0m") -> String {
        
        var wholeString = ""
        
        /* If there's more than 0 days */
        if days > 0 {
            
            /* Handle the days, including the conditional s */
            wholeString += "\(days) day"
            wholeString += days > 1 ? "s" : ""
        }
        
        /* If there's more than 0 hours */
        if hours > 0 {
            
            /* If we've already written to the string, add a space */
            wholeString += wholeString != "" ? " " : ""
            
            /* Handle the hours, including the conditional s */
            wholeString += "\(hours) hr"
            wholeString += hours > 1 ? "s" : ""
        }
        
        /* If there's more than 0 minutes */
        if minutes > 0 {
            
            /* If we've already written to the string, add a space */
            wholeString += wholeString != "" ? " " : ""
            
            /* Handle the minutes, including the conditional s */
            wholeString += "\(minutes) min"
            wholeString += minutes > 1 ? "s" : ""
        }
        
        /* Return the string, or if there's nothing the defaultString */
        return wholeString != "" ? wholeString : defaultString
    }
    
    init(id: UUID = UUID(), timeDelta: Int) {
        self.id = id
        self.time = timeDelta
    }
    
    init(delta: Timedelta) {
        self.id = delta.id
        self.time = delta.time
    }
    
    init(id: UUID = UUID(), days: Int = 0, hours: Int = 0, minutes: Int = 0) {
        self.id = id
        self.time = 0
        self.days = days
        self.hours = hours
        self.minutes = minutes
    }
    
    init(codedString: String) {
        let decoder = JSONDecoder()
        do {
            /* Convert back to data and decode the object */
            let data = codedString.data(using: .utf8)!
            self = try decoder.decode(Timedelta.self, from: data)
        }
        catch {
            self.init()
        }
    }
    
    
    func encodeToString() -> String {
        
        /* Create an encoder */
        let encoder = JSONEncoder()
        
        do {
            
            /* Encode the Timedelta */
            let retVal = try encoder.encode(self)
            
            /* Convert to string and return */
            return String(data: retVal, encoding: .utf8) ?? ""
        }
        catch {
            return ""
        }
    }
    
}
