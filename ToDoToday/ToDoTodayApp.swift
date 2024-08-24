//
//  LifeLogApp.swift
//  LifeLog
//
//  Created by Douglas Inglis on 30/04/2023.
//

import SwiftUI
import WidgetKit
import BackgroundTasks

@main
struct ToDoTodayApp: App {
    
    init() {
        /* Setup background app refreshing */
        registerTask()
        setupAppRefresh()
    }

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                HomeView()
            }
            .implementPopupView()
            .task {
                /* Load the purchases */
                await PurchasePreferences.shared.load()
            }
            
            
            /* Reload notifications when app is started and shut */
            .onReceive(NotificationCenter.default.publisher(
                for: UIScene.willEnterForegroundNotification)) { _ in
                    WidgetCenter.shared.reloadAllTimelines()
                    
                }
        }
    }
    
    func registerTask() {
        /* Register the task */
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.synackuk.ToDoToday.PrepareNotifications", using: nil) { task in
            /* Perform a reset */
            ToDoDataController.shared.performReset()
            /* Setup the next refresh */
            setupAppRefresh()
            /* Mark as complete */
            task.setTaskCompleted(success: true)
        }

    }
    
    func setupAppRefresh() {
        
        /* Schedule a background refresh */
        let request = BGAppRefreshTaskRequest(identifier: "com.synackuk.ToDoToday.PrepareNotifications")
        /* Refresh at the start of each day */
        request.earliestBeginDate = Date().addTime(day: 1).startOfDay
        /* Submit the refresh */
        try? BGTaskScheduler.shared.submit(request)
    }
}
