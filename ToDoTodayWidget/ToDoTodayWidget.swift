//
//  LifeLogWidget.swift
//  LifeLogWidget
//
//  Created by Douglas Inglis on 17/05/2023.
//

import Foundation
import WidgetKit
import SwiftUI

/* Nessecary for iOS 16 + 17 support */
extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        #if os(watchOS)
        if #available(watchOS 10.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        }
        #else
        if #available(iOSApplicationExtension 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        }
        #endif
        return background(backgroundView)
    }
}


struct Provider: TimelineProvider {
    
    /* Define the placeholder while we wait for our timeline to finish */
    func placeholder(in context: Context) -> ToDoTodayEntry {
        
        return ToDoTodayEntry(date: Date(), models: ToDoDataController.shared.timeBasedItems)
    }
    
    /* Define the snapshot for when people preview the widget */
    func getSnapshot(in context: Context, completion: @escaping (ToDoTodayEntry) -> ()) {
        let entry = ToDoTodayEntry(date: Date(), models: ToDoDataController.shared.timeBasedItems)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [ToDoTodayEntry] = []
        
        
        let controller = ToDoDataController()
        
        /* We get between 40 and 70; no reason not to be optimistic */
        var budget = 70
        
        let midnight = Date().startOfDay
        let startOfTomorrow = midnight.addTime(day: 1)

        /* Set an entry for midnight - so that we don't start with an item completed. */
        
        let items = controller.timeBasedItems.widgetItems(numPieces: 6, currDate: midnight)
        entries.append(ToDoTodayEntry(date: midnight, models: items))
        budget -= 1
        
        /* Setup our timeline, renewing whenever we move to a new item on the timeline */
        for item in controller.timeBasedItems {
            
            /* Budget these items out, assuming we'll use the same number per item (we probably won't) */
            let budgetPerItem: Int = budget/controller.timeBasedItems.count
            
            /* Get items around the current timeline item, based on that items start date */
            let startDate = item.startDate
            let items = controller.timeBasedItems.widgetItems(numPieces: 6, currDate: startDate)
            
            /* Setup 20 items over the time the model's running for, to keep things pretty */
            
            var entryDates = [item.startDate]
            if item.startDate.timeDeltaInSeconds(date: item.endDate) > 0 {
                let secondsDelta = item.startDate.timeDeltaInSeconds(date: item.endDate)
                var delta = Int(secondsDelta/(budgetPerItem-2))
                if delta <= 0 {
                    delta = 1
                }
                if delta > secondsDelta {
                    delta = secondsDelta
                }
                let entrySecondsForModel = Array(stride(from: 0, to: secondsDelta, by: delta))
                entryDates = entrySecondsForModel.map({item.startDate.addTime(second: $0)})
                entryDates.append(item.endDate)
                entryDates.append(item.endDate.addTime(minute: 5))
                
            }
            for entryDate in entryDates {
                entries.append(ToDoTodayEntry(date: entryDate, models: items))
            }
            budget -= entryDates.count
            
        }
        
        
        /* Create our timeline */
        let timeline = Timeline(entries: entries, policy: .after(startOfTomorrow))
        completion(timeline)
    }
}

struct ToDoTodayEntry: TimelineEntry {
    var date: Date
    let models: [ToDoModel]
}

struct ToDoTodayWidgetEntryView : View {
    @Environment(\.widgetFamily) var widgetFamily
    
    var entry: Provider.Entry
    var body: some View {
        VStack {
            
            /* If there's no models then just produce an error */
            if entry.models.count == 0 {
                Text("No items on the timeline today!")
                    .padding()
            }
            else {
                
                /* Otherwise switchcase based on the type of widget */
                switch widgetFamily {
#if !os(watchOS)
                case .systemSmall:
                    smallWidget()
                case .systemMedium, .systemLarge, .systemExtraLarge:
                    largeWidget()
#endif
                case .accessoryInline:
                    inlineWidget()
                case .accessoryCircular:
                    circularWidget()
                case .accessoryRectangular:
                    rectangularWidget()
                default:
                    Text("Widget unavailable")
                        .padding()
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        #if os(watchOS)
        .widgetBackground(Color(.black))
        #else
        .widgetBackground(Color(.systemBackground))
        #endif
        
    }
    
    func inlineWidget() -> some View {
        
        /* Get the first model */
        let model: ToDoModel = entry.models.widgetItems(numPieces: 1, currDate:entry.date)[0]
        
        /* Just show the to do title */
        return HStack {
            Text(model.title)
                .lineLimit(1)
        }
    }
    
    func circularWidget() -> some View {
        
        /* Get the first model */
        let model: ToDoModel = entry.models.widgetItems(numPieces: 1, currDate:entry.date)[0]
        
        /* Stack the progress indicator and icon */
        return ZStack {
            
            /* Create a progress indicator */
            CircularProgressIndicator(model: model, shouldShowCheck: false)
            
            /* Add the todos icon */
            Image(systemName: model.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width:30, height:30)
        }
        .padding(.all, 2)
    }
    
    func rectangularWidget() -> some View {
        
        /* Get the first model */
        let model: ToDoModel = entry.models.widgetItems(numPieces: 1, currDate:entry.date)[0]
                
        /* Create a VStack */
        return VStack {
            HStack {
                
                /* Stack the progress indicator and icon */
                ZStack {
                    
                    /* Create a progress indicator */
                    CircularProgressIndicator(model: model, shouldShowCheck: false)
                        .frame(width:45, height:45)
                    
                    /* Add the todos icon */
                    Image(systemName: model.icon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width:30, height:30)
                }
                .padding(.leading, 4)
                .padding(.top, 4)
                
                /* Stack of title, timestamp and a progress bar for the amount of time that has passed */
                VStack {
                    Text(model.title)
                        .font(.caption)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .minimumScaleFactor(0.75)
                        .lineLimit(1)
                    Text(model.timeStamp)
                        .font(.caption2)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .lineLimit(1)
                    ProgressView(value:model.startDate.getPercentTimePassed(endDate: model.endDate, nowDate: entry.date), total:1)
                        .tint(model.toDoColour)
                }
            }
            
        }
    }
#if !os(watchOS)
    func smallWidget() -> some View {
        
        /* Get the first model */
        let model: ToDoModel = entry.models.widgetItems(numPieces: 1, currDate:entry.date)[0]
        
        
        /* Stack information inside of progress */
        return ZStack {
                        
            /* Stack title, progress bar of time passed and timestamp inside the progress for the item */
            VStack(spacing: 10) {
                Text(model.title)
                    .font(.headline)
                    .frame(alignment: .center)
                if #available(iOS 17, *) {
                    Button(intent: MakeProgressIntent(id: model.ID), label: {
                        ZStack {
                            /* Create a progress indicator for the model */
                            CircularProgressIndicator(model: model, shouldShowCheck:false)
                                .frame(width:80, height:80)
                            ToDoItemIconView(model: model, frameWidth: 50, circularFrame: true)
                                .frame(maxWidth: 50)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    })
                    .buttonStyle(.plain)
                    .contentShape(Circle())
                }
                else {
                    ZStack {
                        /* Create a progress indicator for the model */
                        CircularProgressIndicator(model: model, shouldShowCheck:false)
                            .frame(width:80, height:80)
                        ToDoItemIconView(model: model, frameWidth: 50, circularFrame: true)
                            .frame(maxWidth: 50)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }

                Text(model.timeStamp)
                    .font(.caption2)
                
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.vertical, 10)
        
    }
    
    func largeWidget() -> some View {
        
        /* Get the models for our widget */
        let models = entry.models.widgetItems(numPieces: (widgetFamily == .systemMedium ? 2 : 4), currDate:entry.date)
        
        
        return VStack(spacing: 0) {
            
            /* For each widget item */
            ForEach(models, id:\.self) { model in
                let index = models.firstIndex(of: model)!
                if index > 0 {
                    TimelineSpacer(startModel: models[index-1], endModel: model, widgetView: true)
                }
                else {
                    Rectangle()
                        .fill(.clear)
                        .frame(height:10)
                }
                
                HStack {
                    ToDoItemIconView(model: model, frameWidth: 50)
                                .frame(maxWidth: 50)
                    HStack {
                        ToDoItemInformationView(model: model, widgetView: true)
                            .frame(maxWidth: .infinity, maxHeight: 65, alignment: .leading)
                        
                        /* Spacer to push progress indicator to the end */
                        Spacer()
                        
                        
                        /* Create a progress indicator for the model */
                        if #available(iOS 17, *) {
                            Button(intent: MakeProgressIntent(id: model.ID), label: {
                                CircularProgressIndicator(model: model)
                                    .frame(width: 45, height:45)
                                    .padding(.trailing, 10)
                            })
                            .buttonStyle(.plain)
                            .contentShape(Circle())
                        }
                        else {
                            CircularProgressIndicator(model: model)
                                .frame(width: 45, height:45)
                                .padding(.trailing, 10)
                            
                        }
                        
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground).cornerRadius(12))
                }
                .fixedSize(horizontal: false, vertical: true)
                .padding(.vertical, 0)
                
            }
            Spacer()
        }
        .padding(.all, 10)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
#endif
}

struct ToDoTodayWidget: Widget {
    let kind: String = "ToDoTodayWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            ToDoTodayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Todays timeline")
        .description("This widget shows todays timeline every day.")
#if !os(watchOS)
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .systemExtraLarge, .systemLarge, .systemMedium, .systemSmall, .accessoryInline])
#else
        .supportedFamilies([.accessoryRectangular, .accessoryCircular, .accessoryInline])
#endif
    }
}

struct LifeLogWidget_Previews: PreviewProvider {
    static var previews: some View {
        ToDoTodayWidgetEntryView(entry: ToDoTodayEntry(date: Date(), models:[]))        
    }
}
