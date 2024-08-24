//
//  DateExtensions.swift
//  LifeLog
//
//  Created by Douglas Inglis on 04/05/2023.
//

import Foundation

extension Date {
    
    var startOfDay: Date {
        /* Get the start of the day by setting the hour, minute and second to 0. */
        return self.setTime(hour: 0, minute: 0, second: 0)
    }
    
    var endOfDay: Date {
        /* Get the end of the day */
        return self.setTime(hour: 23, minute: 59)
    }

    
    var dayOfMonth: Int {
        /* Get the day of the month */
        /* Subtract one as we use this for array indexing */
        return Calendar.current.component(.day, from: self) - 1
    }
    
    var dayOfWeek: Int {
        /* The calendar .weekday component doesn't work properly with a custom start of week, so we use this hack instead... */
        let dateIndicies = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
        return dateIndicies.firstIndex(of: self.formatDate(formatString: "EE"))!
    }
    
    var hour: Int {
        /* Get the hour of the day */
        return Calendar.current.component(.hour, from: self)
    }
    
    var minute: Int {
        /* Get the minute of the hour */
        return Calendar.current.component(.minute, from: self)
    }


    
    var startOfWeek: Date {
        /* Setup a custom calendar with the first weekday set to Monday(as is correct). */
        var customCalendar = Calendar.current
        customCalendar.firstWeekday = 2
        
        /* Get the week that our date represents in our calendar */
        guard let weekForDate = customCalendar.dateInterval(of: .weekOfMonth, for: self)
        else {
            return Date.distantPast
        }
        
        /* Return the start of the week */
        return weekForDate.start
    }
    
    func enumerateWeek() -> [Date] {
                
        /* Prepare an array for each day of the week */
        var weekDays = Array<Date>()
        
        /* Loop through the days of the week (mon -> sun, indexed from 0) */
        (0...6).forEach { day in
            
            /* Get each day of the week */
            guard let newDay = Calendar.current.date(byAdding:.day, value:day, to: self.startOfWeek)
            else {
                
                /* Return nothing if we error */
                return
            }
            
            /* Add the day to the weekdays */
            weekDays.append(newDay)
        }
        
        /* Return the weekdays */
        return weekDays
    }
    
    func prevWeek() -> Date {
        
        /* Subtract 7 days from the current date */
        guard let newDate = Calendar.current.date(byAdding:.day, value:-7, to:self)
        else {
            return Date.distantPast
        }
        return newDate
    }
    
    func nextWeek() -> Date {
        
        /* Add 7 days to the current date */
        guard let newDate = Calendar.current.date(byAdding:.day, value:7, to:self)
        else {
            return Date.distantPast
        }
        return newDate
    }
    
    func formatDate(formatString: String) -> String {
        
        /* Setup a date formatter */
        let formatter = DateFormatter()
        formatter.dateFormat = formatString
        
        /* Return a formatted date */
        return formatter.string(from: self)
        
    }
    
    func doDatesShareATime(date: Date) -> Bool {
        
        /* Compare the day component of two dates */
        return Calendar.current.dateComponents([.hour, .minute], from: self) == Calendar.current.dateComponents([.hour, .minute], from: date)
        
    }
    
    func doDatesShareADay(date: Date) -> Bool {
        
        /* Compare the day component of two dates */
        return Calendar.current.dateComponents([.year, .month, .day], from: self) == Calendar.current.dateComponents([.year, .month, .day], from: date)
        
    }
    
    func getDayDelta(date: Date) -> Int {
        /* Get the delta in days */
        return Calendar.current.dateComponents([.day], from: self, to: date).day!
    }
    
    func getYearDelta(date: Date) -> DateComponents {
        /* Get the delta in years */
        return Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self, to: date)
    }

    func getPercentTimePassed(endDate: Date, nowDate: Date) -> Double {
        if(nowDate < self) {
            return 0
        }
        
        /* Get the time from start to end of our item (in seconds for easy computation) */
        let startToEndDeltaInSecs = self.timeDeltaInSeconds(date: endDate)
        
        /* Get the time that has passed from the start until now (in seconds for easy computation) */
        let startToNowDeltaInSecs = self.timeDeltaInSeconds(date: nowDate)
        
        /* NaN shouldn't destroy the program. */
        if(startToEndDeltaInSecs == 0 && startToNowDeltaInSecs == 0) {
            return 1
        }
        
        
        /* Percentage time complete is the ratio of these two */
        var percentTimeComplete = Double(startToNowDeltaInSecs) / Double(startToEndDeltaInSecs)
        
        /* Clamped at one */
        if (percentTimeComplete > 1) {
            percentTimeComplete = 1
        }
        return percentTimeComplete
        
    }
    func timeDeltaInSeconds(date: Date) -> Int {
        
        /* Super simple - just get the timedelta in seconds! */
        return Calendar.current.dateComponents([.second], from: self, to: date).second!
    }
    
    func timeDeltaInMinutes(date: Date) -> Int {
        
        /* Super simple - just get the timedelta in minutes! */
        return Calendar.current.dateComponents([.minute], from: self, to: date).minute!
    }
    
    func timeDelta(date: Date) -> Timedelta {
        
        /* Super simple - just get the timedelta in seconds! */
        return Timedelta(timeDelta: self.timeDeltaInMinutes(date: date))
    }
    
    
    func setDay(dayDate: Date) -> Date {
                
        /* Convert the other date into components */
        let otherComponents = Calendar
            .current
            .dateComponents([.year, .month, .day], from: dayDate)
                
        /* Return the new date */
        return self.setTime(year: otherComponents.year, month: otherComponents.month, day: otherComponents.day)
        
    }
    
    func setTime(timeDate: Date) -> Date {
                
        /* Convert the other date into components */
        let otherComponents = Calendar
            .current
            .dateComponents([.hour, .minute, .second], from: timeDate)
                
        /* Return the new date */
        return self.setTime(hour: otherComponents.hour, minute: otherComponents.minute, second: otherComponents.second)
        
    }
    
    func setTime(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: self)
        
        /* Set the year if we're to set it */
        if year != nil {
            components.year = year
        }
        
        /* Set the month if we're to set it */
        if month != nil {
            components.month = month
        }
        
        /* Set the day if we're to set it */
        if day != nil {
            components.day = day
        }
        
        /* Set the hour if we're to set it */
        if hour != nil {
            components.hour = hour
        }
        
        /* Set the minute if we're to set it */
        if minute != nil {
            components.minute = minute
        }
        
        /* Set the second if we're to set it */
        if second != nil {
            components.second = second
        }
        
        return Calendar
            .current
            .date(from:components)!

    }
    
    func addTime(year: Int? = nil, month: Int? = nil, day: Int? = nil, hour: Int? = nil, minute: Int? = nil, second: Int? = nil) -> Date {
        return Calendar.current.date(byAdding: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute, second: second), to: self)!
    }

    
}
