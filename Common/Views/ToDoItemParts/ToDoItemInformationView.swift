//
//  ToDoItemInformationView.swift
//  ToDo, Today
//
//  Created by Douglas Inglis on 13/06/2023.
//

import SwiftUI

struct ToDoItemInformationView: View {
    
    @ObservedObject var model: ToDoModel
    @State var widgetView = false
    @State var watchView = false

    var comboView: Bool {
        return widgetView || watchView
    }

    
    var body: some View {
        /* Space all the text out */
        VStack(spacing: comboView ? 5 : 10) {
            
            /* Title */
            Text(model.title)
                .font(.headline.bold())
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .minimumScaleFactor(0.7)
                .lineLimit(2)
            /* If this is a multi part item, show the current part */
            if model.goal != "" {
                HStack {
                    Image(systemName: model.isCompleted ? "checkmark.square.fill" : "square")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 15)
                        .animation(.easeInOut, value: model.isCompleted)
                    
                    
                    Text(model.goal)
                        .font(widgetView ? .caption2 : .subheadline)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .minimumScaleFactor(0.7)
                        .lineLimit(widgetView ? 1 : 2, reservesSpace: widgetView)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .animation(.easeInOut, value: model.goal)
            }
            
            /* If this item has notes, show the note */
            if model.notes != "" && !widgetView {
                HStack {
                    
                    Image(systemName: "note.text")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: 15)

                    Text(model.notes)
                        .font(.subheadline)
                        .frame(maxHeight: .infinity, alignment: .top)
                        .minimumScaleFactor(0.7)
                        .lineLimit(widgetView ? 1 : 2, reservesSpace: widgetView)
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if model.timeSheduled || model.dateSheduled || model.notificationDates.count != 0 {
                HStack {
                    
                    /* Time scheduled items show the timestamp */
                    if model.timeSheduled {
                        Label {
                            Text(model.timeStamp)
                                .font(.caption2)
                                .minimumScaleFactor(0.2)
                                .lineLimit(1, reservesSpace: true)
                        } icon: {
                            Image(systemName: "clock")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 15)
                        }
                    }

                    /* If we're not timeshceduled but are datescheduled, indicate it */
                    else if model.dateSheduled {
                        Image(systemName: "calendar")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 15)
                        
                    }
                    
                    if !watchView || !model.timeSheduled {
                        
                        /* Items with notifications show a bell */
                        if model.notificationDates.count != 0 {
                            Image(systemName: "bell.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 15)
                        }
                        
                        /* Repeating items show a repeat symbol */
                        if model.repeatHandler.doesRepeat {
                            Image(systemName: "repeat")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 15)
                        }
                    }
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                if watchView && model.timeSheduled {
                    HStack {
                        /* Items with notifications show a bell */
                        if model.notificationDates.count != 0 {
                            Image(systemName: "bell.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 15)
                        }
                        
                        /* Repeating items show a repeat symbol */
                        if model.repeatHandler.doesRepeat {
                            Image(systemName: "repeat")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(maxWidth: 15)
                        }
                        Spacer(minLength: 0)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            if model.goal == "" && model.notes == "" && !model.dateSheduled {
                Spacer(minLength: 0)
            }
        }
        .frame(minHeight: watchView ? 45 : .none)
        .padding()
    }
}

struct ToDoItemInformationView_Previews: PreviewProvider {
    @StateObject static var model = ToDoModel(ctx: ToDoDataController.shared.viewContext)
    static var previews: some View {
        ToDoItemInformationView(model: model)
    }
}
