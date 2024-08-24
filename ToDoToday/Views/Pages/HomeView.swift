//
//  ListView.swift
//  LifeLog
//
//  Created by Douglas Inglis on 30/04/2023.
//

import SwiftUI
import PopupView

struct HomeView: View {
    @StateObject var mainModel: ToDoViewModel = ToDoViewModel.shared
    @StateObject var preferences: Preferences = Preferences.shared

    @State private var showingToDo: Bool = true
    @State private var showingTimeline: Bool = true
    @State private var showingCategoryPicker: Bool = false
    @State private var isShowingNewView: Bool = false
    @State private var showingOptions: Bool = false
    
    var body: some View {
        ZStack {
            VStack {
                
                /* Date selection toolbar  */
                DateToolbarView(currDate: $mainModel.currDate)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom)
                
                ScrollView {
                    
                    VStack {
                        
                        /* Untimed to do items header */
                        itemHeader(title:"To Do Items", isShowing: $showingToDo)
                        
                        /* Items list */
                        ToDoView()
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: showingToDo ? .infinity : 0)
                            .clipped()
                            .allowsHitTesting(showingToDo)
                            .animation(.easeOut, value: showingToDo)
                            .transition(.slide)
                        
                        
                        /* Spacer to create padding */
                        Spacer(minLength: 50)
                        
                    }
                    .padding(.top)
                    .contentShape(Rectangle())
                    .onDrop(of: ["com.synackuk.LifeLog.customtype.dragdroptype"], delegate: ToDoDropDelegate(isShowing: Binding.constant(false)))
                    
                    VStack {
                        
                        /* Timeline to do items */
                        itemHeader(title:"Timeline", isShowing: $showingTimeline)
                        
                        /* Timeline items */
                        TimelineView()
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: showingTimeline ? .infinity : 0)
                            .clipped()
                            .allowsHitTesting(showingTimeline)
                            .animation(.easeOut, value: showingTimeline)
                            .transition(.slide)
                        
                    }
                    .contentShape(Rectangle())
                    .onDrop(of: ["com.synackuk.LifeLog.customtype.dragdroptype"], delegate: ToDoDropDelegate(isbeingSheduled: true, startTime: mainModel.currDate.setTime(timeDate: Date()).setTime(second: 0), timeDelta: preferences.getDraggedModelTimeDelta(), isShowing: Binding.constant(false)))
                    Spacer(minLength: 60)
                }
                .frame(maxWidth: 800)
            }
            
            /* Setup floating new Item button */
            VStack {
                
                /* Push to bottom */
                Spacer()
                
                HStack {
                    
                    /* Push to right */
                    Spacer()
                    
                    
                    Button(action: {
                        
                        /* Setup button to activate new */
                        isShowingNewView = true
                    }, label: {
                        
                        /* Add a + to the button in the centre */
                        Text("+")
                            .font(.system(.largeTitle))
                            .frame(width: 67, height: 60)
                            .foregroundColor(Color.white)
                            .padding(.bottom, 7)
                        
                    })
                    .background(Color.blue)
                    .cornerRadius(38.5)
                    .padding()
                    .shadow(color: Color.black.opacity(0.3), radius: 3, x: 3, y: 3)
                    
                    
                }
            }
        }
        
        
        /* Navigation bar */
        .navigationTitle(mainModel.currDate.formatDate(formatString: "MMM y"))
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {showingCategoryPicker.toggle()}, label: {
                    Image(systemName: "list.bullet")
                })
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {DatePickerPopup(currDate: $mainModel.currDate).showAndStack()}, label: {
                    Image(systemName: "calendar")
                })
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if preferences.homeScreenMode != .copy {
                        preferences.homeScreenMode = .copy
                    }
                    else {
                        preferences.homeScreenMode = .normal
                    }
                }, label: {
                    Image(systemName: preferences.homeScreenMode == .copy ? "doc.on.doc.fill" : "doc.on.doc")
                })
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    if preferences.homeScreenMode != .shunt {
                        preferences.homeScreenMode = .shunt
                    }
                    else {
                        preferences.homeScreenMode = .normal
                    }
                }, label: {
                    Image(systemName: preferences.homeScreenMode == .shunt ? "arrow.down.doc.fill" : "arrow.down.doc")
                })
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showingOptions = true                }, label: {
                        Image(systemName: "info.circle")
                    })
            }
        }
        
        /* Sheets */
        .sheet(isPresented: $showingCategoryPicker) {
            
            CategoryPickerSheet(categories: $mainModel.showingCategories)
        }
        
        /* Sheets */
        .sheet(isPresented: $showingOptions) {
            OptionsSheet()
        }

        
        
        /* Hack to allow us to access newView by tapping */
        .navigationDestination(
            isPresented: $isShowingNewView) {
                newToDoView()
            }
        
        /* Show the lists when items are added to them. */
        .onChange(of: ToDoDataController.shared.toDoItems, perform: { newValue in
            showingToDo = true
        })
        
        .onChange(of: ToDoDataController.shared.timeBasedItems, perform: { newValue in
            showingTimeline = true
        })
        
        
        .onChange(of: mainModel.currDate, perform: { newValue in
            preferences.homeScreenMode = .normal
        })
        .onAppear {
            preferences.homeScreenMode = .normal
        }
    
    }
    
    
    func itemHeader(title: String, isShowing: Binding<Bool>) -> some View {
        return Button(action: {isShowing.wrappedValue.toggle()}, label: {
            HStack {
                Text(title)
                    .font(.title)
                    .foregroundColor(Color(.label))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading)
                Spacer()
                Image(systemName: isShowing.wrappedValue ? "chevron.up" : "chevron.down")
                    .foregroundColor(Color(.label))
                    .padding(.trailing)
            }
            
        })
    }
    
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HomeView()
        }
    }
}

