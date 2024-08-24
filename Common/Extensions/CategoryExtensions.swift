//
//  CategoryExtensions.swift
//  LifeLog
//
//  Created by Douglas Inglis on 17/05/2023.
//

import Foundation
import CoreData
import SwiftUI


extension Category {
    
    /* Passthrough for backing event to avoid optional types */
    var title: String {
        get {
            return backingTitle ?? ""
        }
        set {
            backingTitle = newValue
        }
    }
    
    /* Intiialise category to reasonable defaults */
    convenience init(ctx: NSManagedObjectContext, title: String = "") {
        self.init(context: ctx)
        self.id = UUID()
        self.title = title
    }
    
    /* Create category from other category */
    convenience init(category: Category) {
        self.init(ctx: category.managedObjectContext!, title: category.title)
    }
    
}
