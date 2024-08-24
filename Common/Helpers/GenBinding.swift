//
//  GenBinding.swift
//  ToDo, Today
//
//  Created by Douglas Inglis on 08/06/2023.
//

import Foundation
import SwiftUI


class GenBinding {
    static func genTextToIntBinding(intBinding: Binding<Int>, shouldShowValBinding: Binding<Bool>, minVal: Int = 0, defaultVal: Int = 0, maxVal: Int = .max) -> Binding<String> {
        return Binding(
            get: {
                /* Convert the integer to a string and return, if we're looking at the default value, just have nothing */
                return shouldShowValBinding.wrappedValue ? String(intBinding.wrappedValue) : ""
            },
            set: { newValue in

                shouldShowValBinding.wrappedValue = true
                
                /* Make erasing the text field properly possible */
                if newValue == "" {
                    shouldShowValBinding.wrappedValue = false
                }
                
                /* Convert the int, or failing that use the default value */
                let intVal = Int(newValue) ?? defaultVal
                
                /* If we're below the minimum, return the minimum */
                if intVal < minVal {
                    intBinding.wrappedValue = minVal
                    return
                }
                
                /* If we're above the maxmimum, return the maximum */
                if intVal > maxVal {
                    intBinding.wrappedValue = maxVal
                    return
                }
                
                /* Pass through the wrapped integer */
                intBinding.wrappedValue = intVal
            }
        )
    }
    
    static func genProgressBinding(model: ToDoModel) -> Binding<Decimal> {
        return Binding(
            get: {
                return model.decimalProgress
            },
            set: { newValue in
                
                model.decimalProgress = newValue
            }
        )
    }
        
    static func genTimeToIntBinding(startDate: Binding<Date>, endDate: Binding<Date>, isStart: Bool, isHours: Bool) -> Binding<Int> {
        return Binding(
            get: {
                
                /* Work out what date we're working with */
                let dateToGet = isStart ? startDate.wrappedValue : endDate.wrappedValue
                
                /* If we're working on hours, get the number of hours */
                if isHours {
                    return dateToGet.hour
                }
                
                /* Else get the number of minutes */
                return dateToGet.minute
            },
            set: { newValue in
                
                /* Work out what date we're working with */
                let dateToGet = isStart ? startDate : endDate
                
                /* Set the new hour or minute depending on what kind of binding we are */
                let newHour = isHours ? newValue : nil
                let newMinute = isHours ? nil : newValue
                
                /* Set the new time */
                dateToGet.wrappedValue = dateToGet.wrappedValue.setTime(hour: newHour, minute: newMinute)
                
                /* Make sure the end date isn't before the start date */
                if endDate.wrappedValue < startDate.wrappedValue {
                    endDate.wrappedValue = startDate.wrappedValue
                }
            }
        )
    }
}
