//
//  TimelineView.swift
//  LifeLog
//
//  Created by Douglas Inglis on 30/04/2023.
//

import SwiftUI

struct TimelineView: View {
    @StateObject var mainModel: ToDoViewModel = ToDoViewModel.shared
    @StateObject private var currTimeModal: CurrTimeModel = CurrTimeModel.shared
    @StateObject private var preferences: Preferences = Preferences.shared
    @State private var showingNewToDo = false
    @State private var newStartDate: Date = .distantPast
    @State private var newEndDate: Date = .distantFuture
    
    var body: some View {
        
        /* Stack the timeline vertically */
        VStack(spacing: 0) {
            
            /* Get the items, sorted based on their start time */
            ForEach(mainModel.timeBasedItems, id:\.self) { model in
                
                /* Get the index of our model */
                let i: Int = mainModel.timeBasedItems.firstIndex(where: {model.id == $0.id})!
                
                /* Add our todo item */
                ToDoItem(model: model)
                
                /* We don't add spacers to the last item in the list */
                if (i + 1) < mainModel.timeBasedItems.count {
                    
                    /* Get the start and end date for our spacers */
                    let startDate = model.endDate
                    let endDate = mainModel.timeBasedItems[i + 1].startDate
                    
                    /* If our items don't overlap */
                    if  startDate <= endDate {
                        ZStack {
                   
                            /* Create our spacer */
                            TimelineSpacer(startModel: model, endModel: mainModel.timeBasedItems[i + 1])
                            
                            /* Overlay the spacing button if appropriate */
                            if startDate.timeDeltaInMinutes(date: endDate) >= 30 {
                                toDoAddButton(startDate: startDate, endDate: endDate)
                            }
                            
                            /* Overlay our invisible seperaters in order to support drag and drop properly */
                            ToDoDropSet(startDate: startDate, endDate: endDate)
                                .allowsHitTesting(preferences.isDragging)
                        }
                    }
                    else {
                        
                        /* If the items do overlap, add a warning to the items */
                        HStack {
                            Spacer()
                            Image(systemName: "exclamationmark.octagon.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color(.systemRed))
                                .padding()
                        }
                    }
                }
                
            }
            .navigationDestination(
                isPresented: $showingNewToDo) {
                    newToDoView(startDate: newStartDate, endDate: newEndDate, isTimeScheduled: true, isDateScheduled: true)
                }
            
        }
        
    }
    
    func toDoAddButton(startDate: Date, endDate: Date) -> some View {
        
        /* Get some initial variables */
        let timeDelta = startDate.timeDelta(date: endDate)
        let timeDeltaString = timeDelta.timeString()
        
        return HStack {
            Button(action: {
                /* Set the appropriate variables */
                newStartDate = startDate
                newEndDate = endDate
                showingNewToDo = true
            }, label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Do something for \(timeDeltaString)?")
                        .font(.caption)
                        .foregroundColor(Color(.label))
                        .lineLimit(2)
                }
                .padding(10)
                .background(Color(.secondarySystemBackground).cornerRadius(12))
            })
        }
        .padding(.leading, 60)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct ToDoDropSet: View {
    var startDate: Date
    var endDate: Date

    var body: some View {
        /* Get some variables to start */
        let minuteDelta = startDate.timeDeltaInMinutes(date:endDate)
        let totalHeight = TimelineSpacer.timelineHeightCalc(startDate: startDate, endDate: endDate)
        let minuteSwitch = minuteDelta > 15 ? 5 : 1
        let minutes = 0...(minuteDelta/minuteSwitch)

        /* No spacing or we'd have a disaster */
        VStack(spacing:0) {
            ForEach(minutes, id: \.self) { i in
                let time = startDate.addTime(minute: i * minuteSwitch).setTime(second: 0)
                ToDoDropPart(time: time)
            }
        }
        .frame(height:totalHeight > 10 ? totalHeight-20 : 0)
        .padding(.vertical, totalHeight > 10 ? 10 : 0)
    }
}

struct ToDoDropPart: View {
    var time: Date
    
    @State private var isShowing = false
    @State private var preferences = Preferences.shared
    
    var body: some View {
        /* Clear rectangles with our drop handling */
        HStack {
            Text(time.formatDate(formatString: "HH:mm"))
                .font(.caption2)
                .frame(maxHeight: isShowing ? .infinity : 0)
                .foregroundColor(isShowing ? Color(.label) : .clear)
            Spacer()
        }
        .padding(.leading, 44)
        .frame(maxWidth:.infinity, maxHeight:.infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onDrop(of: ["com.synackuk.LifeLog.customtype.dragdroptype"], delegate: ToDoDropDelegate(isbeingSheduled: true, startTime:time, timeDelta: preferences.getDraggedModelTimeDelta(), isShowing: $isShowing))
    }
}


struct TimelineView_Previews: PreviewProvider {
    static var previews: some View {
        TimelineView()
    }
}
