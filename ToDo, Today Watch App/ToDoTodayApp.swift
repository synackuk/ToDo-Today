//
//  ToDoTodayApp.swift
//  ToDo, Today Watch App
//
//  Created by Douglas Inglis on 18/06/2023.
//

import SwiftUI

@main
struct ToDoToday_App: App {
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        /* When app is brought back to the foreground we need to go to todays date. */
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                ToDoDataController.shared.currDate = Date()

            }
            
        }
    }
}
