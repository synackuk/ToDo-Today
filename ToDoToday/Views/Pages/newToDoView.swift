//
//  newToDoView.swift
//  LifeLog
//
//  Created by Douglas Inglis on 01/05/2023.
//

import SwiftUI
import Combine
import WidgetKit
import StoreKit

struct newToDoView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.requestReview) var requestReview
    
    @State var ID: String = ""
    @State var titleFieldText: String = ""
    @State var notesTextField: String = ""
    @State var subToDoItems: [SubToDoItem] = []
    @State var chosenColour: Color = .yellow
    @State var chosenImage: String = "drop.fill"
    @State var startDate: Date = Date()
    @State var endDate: Date = Date()
    @State var isTimeScheduled: Bool = false
    @State var isDateScheduled: Bool = false
    @State var isLocked: Bool = false
    @State var completedUnits: Int = 1
    @State var autocomplete: Bool = false
    @State var toDoType: ToDoType = .singlePart
    @State var repeatHandler: RepeatHandler? = nil
    @State var notificationDates: [Timedelta] = []
    @State var progress: Int = 0
    @State private var shouldShowCompletedUnits = true
    
    @State var sheetIsOpen: [Bool] = Array(repeating: false, count: 7)
    @State private var howToHandleUpdates: RepeatUpdateBehaviour = .default_choice
    
    @State private var didRepeat = false
    
    @State var categories: [Category] = []
    
    @StateObject private var purchasePrefs = PurchasePreferences.shared
        
    private var isCompleted: Binding<Bool> {
        Binding(
            get: {
                /* If the progress == 0 the item isn't complete */
                return progress != 0
            },
            set: { newValue in
                /* True means progress = 1, false = 0 */
                progress = newValue ? 1 : 0
            }
        )
    }
    
    private var progressProxy: Binding<Double> {
        Binding(
            get: {
                /* Passthrough Double */
                return Double(progress)
            },
            set: { newValue in
                /* Pass back to int */
                progress = Int(newValue)
                
            }
        )
    }
    
    
    var body: some View {
        ScrollView {
            
            /* Space at the top of the screen */
            Spacer(minLength: 25)
            
            
            VStack(spacing:25) {
                
                /* Title text entry */
                VStack {
                    Text("What's the title for your goal?")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    /* Title field */
                    TextField("Enter a title for your item", text: $titleFieldText)
                        .padding()
                        .frame(height: 55)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }
                
                /* Item type selection */
                VStack {
                    
                    
                    /* Item Type  */
                    Text("What type of item is this?")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    
                    Picker("Type", selection: $toDoType, content: {
                        Text("Single part Item")
                            .tag(ToDoType.singlePart)
                        Text("Multipart Item")
                            .tag(ToDoType.multiPart)
                        Text("Goal")
                            .tag(ToDoType.goal)
                    })
                    .pickerStyle(.segmented)
                    .padding(.bottom)
                    
                    /* Each type of item has a different set of options */
                    VStack {
                        if toDoType == .goal {
                            
                            /* If it's a goal then choose the number of units */
                            Text("How many units do you need to complete?")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            /* The number of units bound up */
                            TextField("Units", text: GenBinding.genTextToIntBinding(intBinding: $completedUnits, shouldShowValBinding: $shouldShowCompletedUnits, minVal: 1, defaultVal: 1))
                                .padding()
                                .frame(height: 55)
                                .background(Color(.secondarySystemBackground))
                                .cornerRadius(12)
                                .keyboardType(.numberPad)
                            
                            /* Get the total progress */
                            Text("Total progress: \(progress)/\(completedUnits)")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            /* Add a completion slider */
                            Slider(value: progressProxy, in: 0...Double(completedUnits), step:1)
                            
                            
                        }
                        else if toDoType == .multiPart {
                            
                            /* If it's multipart then allow people to choose what items to add to the list */
                            Text("What does this involve?")
                                .frame(maxWidth: .infinity, alignment: .leading)
                            SubToDoView(subToDoItems: $subToDoItems)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        else {
                            
                            /* Simple toggle whether the item is completed */
                            Toggle("Is this item completed?", isOn: isCompleted)
                            
                        }
                    }
                }
                
                /* Two framed icons for colour and the image */
                HStack {
                    
                    /* Image select button */
                    ButtonWithFrame(title: "Image", action: {sheetIsOpen[0] = true}, frame: {
                        Image(systemName: chosenImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(chosenColour)
                    })
                    
                    /* Colour select button */
                    ButtonWithFrame(title: "Colour", action: {sheetIsOpen[3] = true}, frame: {
                        Circle().fill(chosenColour)
                        
                    })
                }
                
                VStack {
                    
                    /* Time select button */
                    Button(action:{sheetIsOpen[5] = true}) {
                        HStack {
                            Text("Time (optional)")
                                .font(.headline)
                                .foregroundColor(Color(.label))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            /* Time scheduled items get extra pieces */
                            VStack {
                                Text(isTimeScheduled ? "from: " + startDate.formatDate(formatString: "HH:mm") : "")
                                    .font(.caption2)
                                    .foregroundColor(.accentColor)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                
                                Text(isTimeScheduled ? "to: " + endDate.formatDate(formatString: "HH:mm") : "")
                                    .font(.caption2)
                                    .foregroundColor(.accentColor)
                                    .frame(maxWidth: .infinity, alignment: .trailing)
                                
                            }
                            .padding(.trailing, 10)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            
                            Image(systemName: "clock.fill")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color(.label))
                                .frame(width:30, height:30)
                                .padding(.trailing, 10)
                            
                        }
                        .padding(10)
                    }
                    .frame(height:55)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                    /* Date select button */
                    
                    Button(action:DateScheduledPopup(startDate: $startDate, endDate: $endDate, isScheduled: $isDateScheduled).showAndStack) {
                        HStack {
                            Text("Date (optional)")
                                .font(.headline)
                                .foregroundColor(Color(.label))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            /* Date shceduled gets extra pieces */
                            Text(isDateScheduled ? startDate.formatDate(formatString: "dd/MM/yyyy") : "")
                                .font(.caption2)
                                .foregroundColor(.accentColor)
                                .padding(.trailing, 10)
                            
                            Image(systemName: "calendar")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color(.label))
                                .frame(width:30, height:30).padding(.trailing, 10)
                            
                            
                        }
                        .padding(10)
                    }
                    .frame(height:55)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                    
                }
                
                /* Only show these components if we're date scheduled */
                if isDateScheduled && repeatHandler != nil {
                    
                    /* Repeat settings */
                    VStack {
                        
                        Text("Should this item repeat?")
                            .frame(maxWidth: .infinity, alignment: .leading)
                        RepeatingPickerView(repeatHandler: repeatHandler!)
                        
                    }
                    
                    /* Notification settings */
                    VStack {
                        
                        NotificationHandlerSubView(notificationDates: $notificationDates, isTimed: $isTimeScheduled)
                    }
                }
                
                VStack {
                    
                    /* Category select button */
                    Button(action:{sheetIsOpen[4] = true}) {
                        HStack {
                            
                            Text("Select Categories")
                                .font(.headline)
                                .foregroundColor(Color(.label))
                                .frame(maxWidth: .infinity, alignment: .leading)
                            
                            Image(systemName: "list.bullet")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color(.label))
                                .frame(width:30, height:30).padding(.trailing)
                            
                            
                        }
                        .padding(10)
                    }
                    .frame(height:55)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(12)
                }
                
                
                VStack {
                    
                    /* Notes field */
                    TextField("Notes...", text: $notesTextField,  axis: .vertical)
                        .padding()
                        .lineLimit(4...4)
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(12)
                }
                
                
                /* Save button */
                Button(action:saveToDo, label: {
                    Text("Save")
                        .font(.title3)
                        .foregroundColor(Color(.white))
                        .frame(maxWidth: .infinity, alignment: .center)
                })
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.accentColor)
                .cornerRadius(12)
                
                /* Delete Button */
                HStack {
                    if ID != "" {
                        Button(action:{sheetIsOpen[1] = true}, label: {
                            Text("Delete")
                                .font(.title3)
                                .foregroundColor(Color(.white))
                                .frame(maxWidth: .infinity, alignment: .center)
                        })
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemRed))
                        .cornerRadius(12)
                    }
                }
                
                /* Sheets */
                .sheet(isPresented: $sheetIsOpen[0]) {
                    IconChooserSheet(chosenIcon: $chosenImage, chosenColour: chosenColour)
                }
                
                .sheet(isPresented: $sheetIsOpen[4]) {
                    CategoryPickerSheet(categories: $categories, isShowingExtras: false)
                }
                
                .sheet(isPresented: $sheetIsOpen[5]) {
                    TimePickerSheet(startDate: $startDate, endDate: $endDate, isTimed: $isTimeScheduled, autocomplete: $autocomplete, isLocked: $isLocked)
                }
                
                .sheet(isPresented: $sheetIsOpen[6]) {
                    BuyProSheet()
                }

                
                .colourPickerSheet(isPresented: $sheetIsOpen[3], selection: $chosenColour)
                
                /* Deletion Confirmation */
                .confirmationDialog(
                    "Are you sure?",
                    isPresented: $sheetIsOpen[1],
                    titleVisibility: .visible
                ) {
                    Button("Yes", role:.destructive) {
                        withAnimation {
                            deleteToDo()
                        }
                    }
                }
                .alert("What events should be updated", isPresented: $sheetIsOpen[2]) {
                    Button("All events", action: {howToHandleUpdates = .allUpdate})
                    Button("Future events", action: {howToHandleUpdates = .futureUpdate})
                    Button("Just this event", action: {howToHandleUpdates = .singleUpdate})
                    Button("Cancel", role: .cancel, action: {howToHandleUpdates = .cancel})
                }
                
            }
            .padding(.horizontal)
            .animation(.default, value: repeatHandler?.repeatClass ?? .none)
            .navigationTitle(ID == "" ? "Add an item" : "Edit an item")
            
            
            .onAppear {
                
                /* Disable time model updates */
                CurrTimeModel.shared.shouldUpdate = false
                
                /* On appear, set a start and end date if the ID's not set, or if the item isn't timescheduled. */
                if !isTimeScheduled {
                    startDate = ToDoViewModel.shared.currDate.setTime(second: 0).setTime(timeDate: Date())
                    endDate = ToDoViewModel.shared.currDate.setTime(second: 0).setTime(timeDate: Date())
                }
                
                /* Add a repeat handler if we don't have one */
                if repeatHandler == nil {
                    repeatHandler = RepeatHandler(startDate: startDate)
                }
                
                /* If the repeat class isn't none to start with, and we have an ID - it did repeat */
                if repeatHandler!.repeatClass != .none && ID != "" {
                    didRepeat = true
                }
                
            }
            
            /* Reset progress when the toDoType changes, and ensure purchase preferences */
            .onChange(of: toDoType) { newValue in
                progress = 0
                if !purchasePrefs.isProUser && toDoType != .singlePart {
                    sheetIsOpen[6] = true
                    toDoType = .singlePart
                }
            }
            
            /* Make sure date and time schedule are in sync */
            .onChange(of: isTimeScheduled) { newValue in
                isDateScheduled = newValue
            }
            .onChange(of: isDateScheduled) { newValue in
                if !newValue {
                    isTimeScheduled = newValue
                }
            }
            .onDisappear {
                /* Enable time model updates */
                CurrTimeModel.shared.shouldUpdate = true

            }
            .padding(.bottom)
        }
        .frame(maxWidth: 800)
    }
    
    func getWhatToDoWithRepeats() {
        
        /* Open the alert and wait until it's dismissed */
        sheetIsOpen[2] = true
        while(sheetIsOpen[2]) {}
    }
    
    func saveToDo() {
        
        /* Do this asynchronously in order to prevent the while loop freezing the UI */
        DispatchQueue.global(qos: .userInitiated).async {
            
            /* If this is a repeated item we need to know what to do with it */
            if didRepeat {
                getWhatToDoWithRepeats()
            }
            
            /* Back to the main queue in order to allow us to dismiss things */
            DispatchQueue.main.async {
                
                /* Check for success, and pass saving over to to the model */
                let success = ToDoViewModel.shared.saveToDo(ID: ID, title: titleFieldText, notes: notesTextField, icon: chosenImage, progress: progress, completedUnits: completedUnits, toDoColour: chosenColour, startDate: startDate, endDate: endDate, timeSheduled: isTimeScheduled, dateSheduled: isDateScheduled, locked: isLocked, repeatHandler: repeatHandler!, notificationDates: isDateScheduled ? notificationDates : [], categories: categories, autocomplete: autocomplete, toDoType: toDoType, subToDoItems: subToDoItems, repeatUpdateBehaviour: howToHandleUpdates)
                
                /* Set the update back to default */
                howToHandleUpdates = .default_choice
                
                /* If the save was successful, dismiss the page */
                if success {
                    WidgetCenter.shared.reloadAllTimelines()
                    dismiss()
                }
                if Preferences.shared.shouldRequestReview {
                    requestReview()
                }
            }
        }
    }
    
    func deleteToDo() {
        
        /* Do this asynchronously in order to prevent the while loop freezing the UI */
        DispatchQueue.global(qos: .userInitiated).async {
            
            /* If this is a repeated item we need to know what to do with it */
            if repeatHandler!.doesRepeat && ID != "" {
                getWhatToDoWithRepeats()
            }
            
            /* Back to the main queue in order to allow us to dismiss things */
            DispatchQueue.main.async {
                
                /* Check for success and have the main model delete the to do */
                let success = ToDoViewModel.shared.deleteToDo(ID: ID, repeatUpdateBehaviour: howToHandleUpdates)
                
                /* Set the update back to default */
                howToHandleUpdates = .singleUpdate
                
                /* If the save was successful, dismiss the page */
                if success {
                    dismiss()
                }
            }
        }
        
    }
}
struct newToDoView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            newToDoView()
        }
    }
}
