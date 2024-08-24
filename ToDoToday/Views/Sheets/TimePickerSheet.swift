//
//  DatePickerSheet.swift
//  LifeLog
//
//  Created by Douglas Inglis on 03/05/2023.
//

import SwiftUI
import PopupView

struct TimePickerSheet: View {
    @Environment(\.dismiss) var dismiss
        
    @Binding var startDate: Date
    @Binding var endDate: Date
    @Binding var isTimed: Bool
    @Binding var autocomplete: Bool
    @Binding var isLocked: Bool
    
    
    var body: some View {
        VStack {
            
            /* Exit Button */
            ExitButtonView(dismiss: dismiss.callAsFunction)
            
            
            /* Whether the event is timed or not */
            HStack {
                
                Text("Is this event")
                
                
                Picker("type of event", selection: $isTimed, content: {
                    Text("Untimed").tag(false)
                    Text("Timed").tag(true)
                    
                })
                .pickerStyle(.segmented)
                
            }
            .padding()
            
            /* Dividing Line */
            Divider()
                .opacity(isTimed ? 1 : 0)
                .animation(.easeInOut, value: isTimed)
            
            /* Add an option for autocompletion */
            Toggle("Should this event autocomplete?", isOn: $autocomplete)
                .padding()
                .disabled(!isTimed)
                .opacity(isTimed ? 1 : 0)
                .animation(.easeInOut, value: isTimed)
            
            /* Add an option for locking */
            Toggle("Should this event be locked when shunting?", isOn: $isLocked)
                .padding()
                .disabled(!isTimed)
                .opacity(isTimed ? 1 : 0)
                .animation(.easeInOut, value: isTimed)
            
            /* Time picker presets */
            TimePresetPickerView(startDate: $startDate, endDate: $endDate)
                .disabled(!isTimed)
                .opacity(isTimed ? 1 : 0)
                .animation(.easeInOut, value: isTimed)

            
            /* Time picker */
            TimePicker(startTime: $startDate, endTime: $endDate)
                .frame(height:200, alignment: .bottom)
                .disabled(!isTimed)
                .opacity(isTimed ? 1 : 0)
                .animation(.easeInOut, value: isTimed)
            
            Spacer()
            
            /* Done Button */
            Button(action:dismiss.callAsFunction, label: {
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
        .implementPopupView()
    }
        
}

struct TimePickerSheet_Previews: PreviewProvider {
    @State static var isOn: Bool = true
    @State static var dat: Date = Date()
    static var previews: some View {
        TimePickerSheet(startDate: $dat, endDate: $dat, isTimed: $isOn, autocomplete: $isOn, isLocked: $isOn)
    }
}
