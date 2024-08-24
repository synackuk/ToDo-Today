//
//  RepeatingPickerView.swift
//  LifeLog
//
//  Created by Douglas Inglis on 11/05/2023.
//

import SwiftUI
import Combine

struct RepeatingPickerView: View {
    @StateObject var repeatHandler: RepeatHandler
        
    @State private var shouldShowRepeatDays = true
    @State private var shouldShowRepeatYears = true

    @StateObject private var purchasePrefs = PurchasePreferences.shared
    @State private var showingBuyOption = false

    
    private var shouldEnd: Binding<Bool> {
        Binding(
            get: {
                /* If the end date is before the 'distant future' constant, we should end */
                return repeatHandler.repeatEndDate < .distantFuture
            },
            set: { newValue in
                
                /* Set the end date to either todays date or the distant future */
                repeatHandler.repeatEndDate = newValue ? Date() : .distantFuture
            }
        )
    }
    
    var body: some View {
        VStack {
            /* Select whether or not we're repeating */
            Picker("", selection: $repeatHandler.repeatClass) {
                Text("No").tag(RepeatClass.none)
                Text("Daily").tag(RepeatClass.day)
                Text("Weekly").tag(RepeatClass.week)
                Text("Monthly").tag(RepeatClass.month)
                Text("Yearly").tag(RepeatClass.year)
            }
            .pickerStyle(.segmented)
            .padding(.bottom)
            
            /* If we are repeating, decide how often */
            VStack {
                if repeatHandler.repeatClass == .day {
                    /* Repeat every n days */
                    HStack {
                        Text("Every")
                        TextField("", text:GenBinding.genTextToIntBinding(intBinding: $repeatHandler.repeatDays, shouldShowValBinding: $shouldShowRepeatDays, minVal: 1, defaultVal: 1))
                            .frame(width:12*4)
                            .background(Color(.secondarySystemBackground))
                        Text("day(s)")
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(AnyTransition.move(edge: .top))
                }
                else if repeatHandler.repeatClass == .week {
                    
                    /* Select days of the week to repeat on */
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach((0...6), id:\.self) { i in
                            weekCalenderButton(index: i)
                        }
                    }
                    .transition(AnyTransition.move(edge: .top))
                }
                else if repeatHandler.repeatClass == .month {
                    
                    /* Select days of the month to repeat on */
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())]) {
                        ForEach((1...31), id:\.self) { i in
                            monthCalenderButton(index: i - 1)
                        }
                    }
                    .transition(AnyTransition.move(edge: .top))
                }
                else if repeatHandler.repeatClass == .year {
                    /* Repeat every n years */
                    HStack {
                        Text("Every")
                        TextField("", text:GenBinding.genTextToIntBinding(intBinding: $repeatHandler.repeatYears, shouldShowValBinding: $shouldShowRepeatDays, minVal: 1, defaultVal: 1))
                            .frame(width:12*4)
                            .background(Color(.secondarySystemBackground))
                        Text("year(s)")
                        
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(AnyTransition.move(edge: .top))
                }
                
                /* Option to choose a repeat end date */
                if repeatHandler.repeatClass != .none {
                    customEndDate()
                }
            }
            .clipped()
            .frame(minWidth: 0, maxWidth: 800, minHeight: 0, maxHeight: repeatHandler.repeatClass == .none ? 0 : .none, alignment: .leading)
            .animation(.default, value: repeatHandler.repeatClass)
            
            
            .onChange(of: repeatHandler.repeatClass, perform: { _ in
                if repeatHandler.repeatClass != .none && !purchasePrefs.isProUser {
                    repeatHandler.repeatClass = .none
                    showingBuyOption = true
                }
            })
            
            .sheet(isPresented: $showingBuyOption) {
                BuyProSheet()
            }

        }
        
    }
    
    func weekCalenderButton(index: Int) -> some View {
        let daysOfTheWeek = ["M", "T", "W", "T", "F", "S", "S"]
        
        /* Toggle the relevent day of the week */
        return Button(action: {repeatHandler.repeatWeeks[index].toggle()}, label: {
            Circle()
                .fill(repeatHandler.repeatWeeks[index] ? Color(.label) : Color(.secondarySystemBackground))
                .overlay {
                    Text(String(daysOfTheWeek[index]))
                        .foregroundColor(repeatHandler.repeatWeeks[index] ? Color(.systemBackground) : Color(.label))
                }
        })
        .animation(.easeInOut.speed(1.5), value: repeatHandler.repeatWeeks[index])
        
    }
    
    func monthCalenderButton(index: Int) -> some View {
        
        /* Toggle the relevent day of the month */
        return Button(action: {repeatHandler.repeatMonths[index].toggle()}, label: {
            Circle()
                .fill(repeatHandler.repeatMonths[index] ? Color(.label) : Color(.secondarySystemBackground))
                .overlay {
                    Text(String(index+1))
                        .foregroundColor(repeatHandler.repeatMonths[index] ? Color(.systemBackground) : Color(.label))
                }
        })
        .animation(.easeInOut.speed(1.5), value: repeatHandler.repeatMonths[index])
        
    }
    
    func customEndDate() -> some View {
        
        /* Allow the user to choose an end date if they wish */
        return VStack {
            DatePicker("Repetition Starts:", selection: $repeatHandler.repeatStartDate, displayedComponents: [.date])
            Toggle("Repetition should end:", isOn: shouldEnd)
            DatePicker("When?", selection: $repeatHandler.repeatEndDate, displayedComponents: [.date])
                .disabled(repeatHandler.repeatEndDate >= .distantFuture)
                .opacity(repeatHandler.repeatEndDate < .distantFuture ? 1 : 0)
                .animation(.easeInOut, value: repeatHandler.repeatEndDate)
            
        }
        .padding(.trailing)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct RepeatingPickerView_Previews: PreviewProvider {
    @State static var repeatHandler: RepeatHandler = RepeatHandler()
    static var previews: some View {
        RepeatingPickerView(repeatHandler: repeatHandler)
    }
}
