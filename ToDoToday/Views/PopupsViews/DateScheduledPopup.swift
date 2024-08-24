//
//  DatePickerSheet.swift
//  LifeLog
//
//  Created by Douglas Inglis on 03/05/2023.
//

import SwiftUI
import PopupView

struct DateScheduledPopup: CentrePopup {    
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var isScheduled: Bool
    
    var currDate: Binding<Date> {
        Binding {
            return startDate
        } set: { newVal in
            startDate = startDate.setDay(dayDate: newVal)
            endDate = endDate.setDay(dayDate: newVal)
        }

    }
    
    func createContent() -> some View {
        VStack {
            
            /* Exit Button */
            ExitButtonView(dismiss: dismiss)
            
            
            /* Whether the event is scheduled or not */
            HStack {
                
                Text("Is this event")
                
                Picker("type of event", selection: $isScheduled, content: {
                    
                    Text("Unscheduled").tag(false)
                    Text("Scheduled").tag(true)
                    
                })
                .pickerStyle(.segmented)
                
            }
            .padding()
            
            /* Dividing Line */
            Divider()
                .opacity(isScheduled ? 1 : 0)
                .animation(.easeInOut, value: isScheduled)
            
            /* Date picker */
            DatePicker("", selection: currDate, displayedComponents: .date)
                .datePickerStyle(.graphical)
                .disabled(!isScheduled)
                .opacity(isScheduled ? 1 : 0)
                .animation(.easeInOut, value: isScheduled)
            
            Button(action:dismiss, label: {
                Text("Done")
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

struct DateScheduledPopup_Previews: PreviewProvider {
    @State static var isOn: Bool = false
    @State static var dat: Date = Date()
    static var previews: some View {
        DateScheduledPopup(startDate: $dat, endDate: $dat, isScheduled: $isOn)
    }
}
