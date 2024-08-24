//
//  WidgetProgressIntent.swift
//  ToDo, Today
//
//  Created by Douglas Inglis on 18/06/2023.
//

import Foundation
import AppIntents


struct MakeProgressIntent: AppIntent {
    static var title: LocalizedStringResource = "Make progress on item"
    @Parameter(title: "Task ID")
    var id: String

    init() {
        self.id = ""
    }
    
    init(id: String) {
        self.id = id
    }
        
    func perform() async throws -> some IntentResult {
        let viewModel = ToDoDataController.shared
        let model = viewModel.toDoForID(id: id)
        model?.makeProgress()
        viewModel.update()
        return .result()
    }
}
