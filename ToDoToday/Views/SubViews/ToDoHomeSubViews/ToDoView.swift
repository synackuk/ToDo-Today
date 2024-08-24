//
//  ToDoView.swift
//  LifeLog
//
//  Created by Douglas Inglis on 01/05/2023.
//

import SwiftUI

struct ToDoView: View {
    @StateObject var mainModel: ToDoViewModel = ToDoViewModel.shared
    @StateObject private var currTimeModal: CurrTimeModel = CurrTimeModel.shared
    @StateObject private var preferences: Preferences = Preferences.shared
    
    var body: some View {
        VStack(spacing: 20) {
            
            /* Get all the untimed to do items */
            ForEach(mainModel.toDoItems, id:\.self) { model in
                ToDoItem(model: model)
            }
        }
        
    }
}

struct ToDoView_Previews: PreviewProvider {
    static var previews: some View {
        ToDoView()
    }
}
