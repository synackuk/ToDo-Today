//
//  TimePresetPickerView.swift
//  ToDo, Today
//
//  Created by Douglas Inglis on 12/06/2023.
//

import SwiftUI

struct TimePresetPickerView: View {
    @Binding var startDate: Date
    @Binding var endDate: Date
    
    @State private var editMode = false

    @StateObject private var preferences = Preferences.shared

    var body: some View {
        VStack {
            /* An edit button for the time presets */
            HStack {
                Spacer()
                Button(editMode ? "Done" : "Edit", action: {
                    withAnimation {
                        editMode.toggle()
                    }
                })
                    .padding(.trailing)
            }
            
            ScrollView(.horizontal) {
                HStack {
                    ForEach(preferences.timePresets) { value in
                        Button(action: {
                            
                            /* If we're in edit mode, open the popup for editting */
                            if editMode {
                                let index = preferences.timePresets.firstIndex(of: value)
                                TimeDeltaPopup(time: $preferences.timePresets[index!]).showAndStack()
                                return
                            }
                            
                            /* Get the end of the day, which we'll use if the time goes over */
                            let endOfDay = startDate.endOfDay
                            
                            /* Calculate the end date */
                            endDate = startDate.addTime(hour: value.hours, minute: value.minutes)
                            
                            
                            /* Restrict us to the end of the day */
                            if endDate > endOfDay {
                                endDate = endOfDay
                            }
                            
                            
                        }, label: {
                            HStack {
                                Text(value.timeString())
                                    .foregroundColor(Color(.label))
                                    .lineLimit(1)
                                if editMode {
                                    Spacer()
                                    Image(systemName: "x.circle.fill")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(Color(.systemRed))
                                        .frame(width: 20, height: 20)
                                        .onTapGesture {
                                            let index = preferences.timePresets.firstIndex(of: value)
                                            preferences.timePresets.remove(at: index!)
                                        }
                                }
                                
                            }
                            .frame(height:20)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .fixedSize()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(12)
                            .animation(.easeInOut, value: editMode)
                        })
                    }
                    
                    if editMode {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color(.secondarySystemBackground))
                            .frame(width: 30, height: 30)
                            .padding(.trailing, 5)
                            .background {
                                Circle()
                                    .fill(Color(.label))
                                    .frame(width:28, height: 28)
                                    .padding(.trailing, 5)
                            }
                            .onTapGesture {
                                let newItem = Timedelta()
                                preferences.timePresets.append(newItem)
                                let index = preferences.timePresets.firstIndex(of: newItem)!
                                TimeDeltaPopup(time: $preferences.timePresets[index]).showAndStack()
                            }
                            .animation(.easeInOut, value: editMode)
                    }
                        
                }
                
            }
            .padding(.horizontal)
        }
    }
}

struct TimePresetPickerView_Previews: PreviewProvider {
    @State static var startDate: Date = .distantPast
    @State static var endDate: Date = .distantFuture
    static var previews: some View {
        TimePresetPickerView(startDate: $startDate, endDate: $endDate)
    }
}
