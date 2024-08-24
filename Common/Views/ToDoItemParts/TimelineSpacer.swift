//
//  TimelineSpacer.swift
//  ToDo, Today
//
//  Created by Douglas Inglis on 19/06/2023.
//

import SwiftUI

struct TimelineSpacer: View {
    @ObservedObject var startModel: ToDoModel
    @ObservedObject var endModel: ToDoModel
    @State var widgetView: Bool = false
    @State var watchView: Bool = false
    
    @State var minHeight: CGFloat = 100
    @State var maxHeight: CGFloat = 150
    
    @State var padding: CGFloat = 30
    
    @StateObject private var preferences = Preferences.shared
    @StateObject private var currTimeModel = CurrTimeModel.shared
    
    #if !os(watchOS)
    @State private var bgColor = Color(.secondarySystemBackground)
    #else
    @State private var bgColor = Color(.darkGray)
    #endif
    var body: some View {
        /* For each widget item */
        HStack {
            if startModel.endDate > endModel.startDate {
                /* If the items do overlap, add a warning to the items */
                HStack {
                    Spacer()
                    Image(systemName: "exclamationmark.octagon.fill")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: (widgetView || watchView) ? 10 : 30, height: (widgetView || watchView) ? 10 : 30)
                        .foregroundColor(Color(.red))
                        .padding()
                }
            }
            else {
                ZStack(alignment: .topLeading) {
                    GeometryReader { geo in
                        timelineSpacerPart(startDate: startModel.endDate, endDate: endModel.startDate, fill: bgColor, shouldBeSolid: widgetView)
                        timelineSpacerPart(startDate: startModel.endDate, endDate: endModel.startDate, fill: LinearGradient(
                            gradient: .init(colors: [startModel.toDoColour, endModel.toDoColour]),
                            startPoint: .top,
                            endPoint: .bottom), shouldBeSolid: widgetView)
                        .mask {
                            Rectangle()
                                .frame(width: 24, height: geo.size.height * startModel.endDate.getPercentTimePassed(endDate: endModel.startDate, nowDate: currTimeModel.currTime), alignment: .leading)
                            Spacer(minLength: 0)
                        }
                    }
                }
                .frame(width:(watchView || widgetView) ? 6 : 12, height: TimelineSpacer.timelineHeightCalc(startDate: startModel.endDate, endDate: endModel.startDate, minHeight: minHeight, maxHeight: maxHeight), alignment: .topLeading)
                .padding(.leading, padding)
                
                if startModel.endDate.timeDeltaInMinutes(date: endModel.startDate) >= 30 && !preferences.isDragging && !widgetView {
                    VStack {
                        
                        /* Mark the end of the current task */
                        Text(startModel.endDate.formatDate(formatString: "HH:mm"))
                            .font(.caption2)
                            .frame(maxWidth:.infinity, maxHeight:.infinity, alignment: .topLeading)
                        
                        /* Mark the start of the next task */
                        Text(endModel.startDate.formatDate(formatString: "HH:mm"))
                            .font(.caption2)
                            .frame(maxWidth:.infinity, maxHeight:.infinity, alignment: .bottomLeading)
                    }
                    .padding(.vertical, 10)
                }
                
                Spacer()
                    .onAppear {
                        if watchView {
                            minHeight = 60
                            maxHeight = 80
                            padding = 20/2
                        }
                        if widgetView {
                            minHeight = 12
                            maxHeight = 12
                            padding = 24
                        }
                    }
            }
        }
    }
    @ViewBuilder func timelineSpacerPart(startDate: Date, endDate: Date, fill: some ShapeStyle, shouldBeSolid: Bool) -> some View {
        
        /* Allow for different behaviour for butted up items */
        let strokeStyle = (startModel.endDate.timeDeltaInMinutes(date: endModel.startDate) <= 5 || shouldBeSolid) ? StrokeStyle(lineWidth: 6) : StrokeStyle(lineWidth: 6, dash: [10])

        VLine()
            .stroke(fill, style: strokeStyle)
        
    }
    static func timelineHeightCalc(startDate: Date, endDate: Date, isTimescheduled: Bool = true, minHeight: CGFloat = 100, maxHeight: CGFloat = 150) -> CGFloat {
        
        if startDate == endDate {
            /* Lower difference in the case when events are butted up against each other */
            return 10
        }
        
        if !isTimescheduled {
            return minHeight
        }
        
        let timedelta:CGFloat = CGFloat(startDate.timeDeltaInMinutes(date: endDate))
        
        if timedelta < 30 {
            return min(maxHeight, max(timedelta, 30))
        }
        
        /* Small min to prevent huge timelines, otherwise just based on the number of minutes */
        return min(maxHeight, max(timedelta, minHeight))
    }
}

struct TimelineSpacer_Previews: PreviewProvider {
    static var previews: some View {
        TimelineSpacer(startModel: ToDoModel(ctx: ToDoDataController.shared.viewContext, title: "Test", icon: "cup.and.saucer", toDoColour: .blue, timeSheduled: true, dateSheduled: true), endModel: ToDoModel(ctx: ToDoDataController.shared.viewContext, title: "Test", icon: "cup.and.saucer", toDoColour: .blue, timeSheduled: true, dateSheduled: true))
    }
}
