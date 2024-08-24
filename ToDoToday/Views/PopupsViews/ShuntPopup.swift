//
//  ShuntPopup.swift
//  LifeLog
//
//  Created by Douglas Inglis on 01/06/2023.
//

import SwiftUI
import PopupView

struct ShuntPopup: CentrePopup {
    @State var startModel: ToDoModel
    @State private var shuntTime: Timedelta = Timedelta()
    @State private var shuntDirection: Int = 1
    
    
    func createContent() -> some View {
        VStack {
            
            /* Exit Button */
            ExitButtonView(dismiss: dismiss)
            
            Text("When should we shunt this to?")
                .font(.title2)
            
            /* Forward or backward */
            
            Picker("", selection: $shuntDirection) {
                Text("Forward").tag(1)
                Text("Backward").tag(-1)
            }
            .pickerStyle(.segmented)
            .padding()
            
            Divider()
            
            
            /* Set hours and minutes */
            TimeDeltaPickerView(time: $shuntTime, showsDays: false)
            
            /* Add go button */
            Button(action:startShunting, label: {
                Text("Shunt")
                    .font(.title3)
                    .foregroundColor(Color(.white))
                    .frame(maxWidth: .infinity, alignment: .center)
            })
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.accentColor)
            .cornerRadius(12)
            .padding()
            
        }
        .frame(maxWidth:480)
        .background(Color(.secondarySystemBackground).cornerRadius(20))
    }

    func startShunting() {
        
        /* Get some initial data */
        let shuntHours: Int = shuntDirection * shuntTime.hours
        let shuntMinutes: Int = shuntDirection * shuntTime.minutes
        var itemsToShunt: [ToDoModel] = []
        
        let startIndex = ToDoDataController.shared.timeBasedItems.firstIndex(of: startModel)!
        
        var prevModelToShunt: ToDoModel? = nil
        
        /* Get all items from the one we shunted */
        for i in ToDoDataController.shared.timeBasedItems.indices {
            if i >= startIndex {
                itemsToShunt.append(ToDoDataController.shared.timeBasedItems[i])
                continue
            }
            prevModelToShunt = ToDoDataController.shared.timeBasedItems[i]
        }
        
        
        /* Get the index of all items */
        for i in itemsToShunt.indices {
            
            /* Get the model */
            let model = itemsToShunt[i]
            
            /* Ignore locking of the first item, since we're shunting it regardless */
            if i != 0 && model.locked {
                continue
            }
            
            /* Calculate the new start and end dates */
            let newStart = model.startDate.addTime(hour: shuntHours, minute: shuntMinutes)
            let newEnd = model.endDate.addTime(hour: shuntHours, minute: shuntMinutes)
            
            /* Assume that the item will stay on the current day */
            var shuntToNextDay = false
            
            /* If we're shunting forward */
            
            if shuntDirection == 1 {
                
                /* If this model isn't the last one */
                
                if model != itemsToShunt.last {
                    
                    /* If the next model is locked, and we're going to overlap it, we must shunt this item to the next day */
                    let nextModel = itemsToShunt[i + 1]
                    if nextModel.locked && newEnd > nextModel.startDate {
                        shuntToNextDay = true
                    }
                }
            }
            else {
                /* Otherwise */
                
                /* If this model isn't the first one, or there's a prevModelToShunt */
                if model != itemsToShunt.first || prevModelToShunt != nil {
                    /* If the previous model will overlap with us, we need to shunt our new item */
                    let prevModel = i > 0 ? itemsToShunt[i - 1] : prevModelToShunt!
                    if newStart < prevModel.endDate {
                        shuntToNextDay = true
                    }
                }
                
            }
            
            /* If the item is already going to the next day, shunt it properly */
            if !newEnd.doDatesShareADay(date: ToDoDataController.shared.currDate) {
                shuntToNextDay = true
            }
            
            
            /* The model no longer repeats */
            model.unlinkFromRepeats()
            
            /* Set the new start and end */
            model.startDate = newStart
            model.endDate = newEnd
            
            if shuntToNextDay {
                
                /* Wipe out the notifications */
                model.notificationDates = []
                
                /* Set the start and end date to the start of the next day */
                model.startDate = ToDoDataController.shared.currDate.addTime(day: 1)
                model.endDate = ToDoDataController.shared.currDate.addTime(day: 1)
                
                /* Item is no longer timescheduled */
                model.timeSheduled = false
            }
            
        }
        
        /* Update the model and dismiss the popup */
        ToDoViewModel.shared.update()
        dismiss()
        
        
        
    }
    
    func configurePopup(popup: CentrePopupConfig) -> CentrePopupConfig {
        popup
#if targetEnvironment(macCatalyst)
            .tapOutsideToDismiss(false)
#endif
            .horizontalPadding(20)
            .cornerRadius(16)
            .backgroundColour(.clear)
        
    }
}

struct ShuntPopup_Previews: PreviewProvider {
    static var previews: some View {
        ShuntPopup(startModel: ToDoModel())
    }
}
