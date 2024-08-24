//
//  TimeDeltaPickerView.swift
//  ToDo, Today
//
//  Created by Douglas Inglis on 08/06/2023.
//

import SwiftUI

struct TimeDeltaPickerView: View {
    @Binding var time: Timedelta
    @State var showsDays: Bool
    @State var showsHoursAndMins: Bool = true
    var body: some View {
        HStack {
            if showsDays {
                timeWheel(bookend: "Days", selection: _time.days, range: 0...364)
            }
            
            if showsHoursAndMins {
                timeWheel(bookend: "Hrs", selection: _time.hours, range: 0...23)
                timeWheel(bookend: "Mins", selection: _time.minutes, range: 0...59)
            }
        }
        .padding()
    }
    
    func timeWheel(bookend: String, selection: Binding<Int>, range: ClosedRange<Int>) -> some View {
        return HStack {
            
            /* A picker with no title */
            Picker("", selection: selection) {
                ForEach(range, id:\.self) { i in
                    
                    /* Remember to tag the text so that selections work */
                    Text(String(format: "%02d", i)).tag(Int(i))
                }
            }
            .pickerStyle(.wheel)
            
            /* Add the bookend text */
            Text(bookend)
        }
    }
}

struct TimeDeltaPickerView_Previews: PreviewProvider {
    @State static var timeDelta = Timedelta()
    static var previews: some View {
        TimeDeltaPickerView(time: $timeDelta, showsDays: true)
    }
}
