//
//  RepeatHandler.swift
//  ToDo, Today
//
//  Created by Douglas Inglis on 10/06/2023.
//

import Foundation

class RepeatHandler: Codable, Identifiable, Equatable, ObservableObject {
    
    var id: UUID
    var repeatStartDate: Date {
        didSet {
            repeatStartDate = repeatStartDate.startOfDay
            objectWillChange.send()
        }
    }
    var repeatEndDate: Date {
        didSet {
            repeatEndDate = repeatEndDate.startOfDay
            objectWillChange.send()
        }
    }
    var repeatClass: RepeatClass {
        didSet {
            objectWillChange.send()
        }
    }
    var repeatDays: Int {
        didSet {
            objectWillChange.send()
        }
    }
    var repeatWeeks: [Bool] {
        didSet {
            objectWillChange.send()
        }
    }
    var repeatMonths: [Bool] {
        didSet {
            objectWillChange.send()
        }
    }
    var repeatYears: Int {
        didSet {
            objectWillChange.send()
        }
    }
    var excludedDates: [Date]  {
        didSet {
            excludedDates = excludedDates.map {$0.startOfDay}
        }
    }
    
    /* Check if the repeat handler does repeat */
    var doesRepeat: Bool {
        return repeatClass != .none
    }
        
    /* Initialise a handler with reasonable defaults */
    init(startDate: Date = Date(), endDate: Date = .distantFuture, repeatClass: RepeatClass = .none, days: Int = 1, weeks: [Bool] = Array(repeating: false, count: 7), months: [Bool] = Array(repeating: false, count: 31), years: Int = 1, excludedDates: [Date] = []) {
        self.id = UUID()
        self.repeatStartDate = startDate
        self.repeatEndDate = endDate
        self.repeatClass = repeatClass
        self.repeatDays = days
        self.repeatWeeks = weeks
        self.repeatMonths = months
        self.repeatYears = years
        self.excludedDates = excludedDates
    }
    
    /* Initialise the handler based on another handler */
    convenience init(handler: RepeatHandler) {
        self.init(startDate: handler.repeatStartDate, endDate: handler.repeatEndDate, repeatClass: handler.repeatClass, days: handler.repeatDays, weeks: handler.repeatWeeks, months: handler.repeatMonths, years: handler.repeatYears, excludedDates: handler.excludedDates)
    }
    
    func doesRepeatToday(currDate: Date) -> Bool {
        
        /* Sanitise date */
        let sanitisedDate = currDate.startOfDay
        
        /* Verify we're not an excluded date */
        
        for excludedDate in excludedDates {
            if sanitisedDate.doDatesShareADay(date: excludedDate) {
                return false
            }
        }
        
        /* Verify we're past the repeat start date */
        if(repeatStartDate > sanitisedDate && !repeatStartDate.doDatesShareADay(date: sanitisedDate)) {
            return false
        }
        
        /* Verify we're before the repeat end date */
        
        if(repeatEndDate < sanitisedDate && !repeatEndDate.doDatesShareADay(date: sanitisedDate)) {
            return false
        }
        
        /* Always return true for the start date, this allows for the start date to be seperate to the repeats */
        if(repeatStartDate.doDatesShareADay(date: sanitisedDate)) {
            return true
        }
        
        
        switch(repeatClass) {
        case .day:
            /* Check if the number of days is our repeat days */
            let numDays = repeatStartDate.getDayDelta(date: sanitisedDate)
            return numDays % Int(repeatDays) == 0
        case .week:
            
            /* Check if this is a repeat day */
            let dayOfWeek = sanitisedDate.dayOfWeek
            return repeatWeeks[dayOfWeek]
            
        case .month:
            
            /* Check if this is a repeat day */
            let dayOfMonth = sanitisedDate.dayOfMonth
            return repeatMonths[dayOfMonth]
            
        case .year:
            
            /* Check if the number of years is our repeat years */
            let numYears = repeatStartDate.getYearDelta(date: sanitisedDate)
            return numYears.day! == 0 && numYears.month! == 0 && numYears.year! > 0 && numYears.year! % Int(repeatYears) == 0
            
        case .none:
            /* If we're not repeating... */
            return false
        }
    }
    
    
    convenience init(codedString: String) {
        let decoder = JSONDecoder()
        do {
            /* Convert back to data and decode the object */
            let data = codedString.data(using: .utf8)!
            self.init(handler: try decoder.decode(RepeatHandler.self, from: data))
        }
        catch {
            self.init()
        }
    }
    
    static func == (lhs: RepeatHandler, rhs: RepeatHandler) -> Bool {
        return lhs.id == rhs.id
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
