//
//  ToDoItemProvider.swift
//  ToDo, Today
//
//  Created by Douglas Inglis on 08/06/2023.
//

import Foundation

class ToDoItemProvider: NSItemProvider {
    deinit {
        /* Crude hack, if you go off the side, we can detect an end to dragging because the Item Provider will be de-initialised */
        DispatchQueue.main.async {
            Preferences.shared.isDragging = false
        }
    }
}
