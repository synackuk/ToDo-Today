//
//  TimePicker.swift
//  LifeLog
//
//  Created by Douglas Inglis on 02/05/2023.
//

import SwiftUI

struct TimePicker: View {
    @Binding var startTime: Date
    @Binding var endTime: Date
        
    var body: some View {
        HStack {
            
            /* Starting Hour */
            Picker("", selection: GenBinding.genTimeToIntBinding(startDate: $startTime, endDate: $endTime, isStart: true, isHours: true)) {
                ForEach((0...23), id:\.self) { i in
                    Text(String(format: "%02d", i))
                }
            }
            .pickerStyle(.wheel)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            
            /* Time deliminator */
            Text(":")
            
            /* Starting Minute */
            Picker("", selection: GenBinding.genTimeToIntBinding(startDate: $startTime, endDate: $endTime, isStart: true, isHours: false)) {
                ForEach((0...59), id:\.self) { i in
                    Text(String(format: "%02d", i))
                }
            }
            .pickerStyle(.wheel)
            
            /* Middle Arrow */
            Image(systemName: "arrowshape.forward.fill")
            
            /* Ending Hour */
            Picker("", selection: GenBinding.genTimeToIntBinding(startDate: $startTime, endDate: $endTime, isStart: false, isHours: true)) {
                ForEach((0...23), id:\.self) { i in
                    Text(String(format: "%02d", i))
                }
            }
            .pickerStyle(.wheel)
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            
            /* Time deliminator */
            Text(":")
            
            /* Ending Minute */
            Picker("", selection: GenBinding.genTimeToIntBinding(startDate: $startTime, endDate: $endTime, isStart: false, isHours: false)) {
                ForEach((0...59), id:\.self) { i in
                    Text(String(format: "%02d", i))
                }
            }
            .pickerStyle(.wheel)
            
        }
    }
}

struct TimePicker_Previews: PreviewProvider {
    @State static var startTime: Date = Date()
    @State static var endTime: Date = Date()
    
    static var previews: some View {
        
        TimePicker(startTime: $startTime, endTime: $endTime)
    }
}
