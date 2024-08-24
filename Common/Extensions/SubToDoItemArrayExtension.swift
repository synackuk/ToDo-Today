//
//  SubToDoItemArrayExtension.swift
//  LifeLog
//
//  Created by Douglas Inglis on 15/05/2023.
//

import Foundation

extension [SubToDoItem] {
    
    /* Get all the items from the array which have a title that's not "" */
    var fixedList: [SubToDoItem] {
        
        /* Filter items where the title (with whitespace trimmed) doesn't equal "" */
        return self.filter {
            $0.title.trimmingCharacters(in: .whitespacesAndNewlines) != ""
        }
    }
    
    var recreatedArray: [SubToDoItem] {
        var out: [SubToDoItem] = []
        
        /* Recreate the whole array, to allow different items to have different sttaes for the same list */
        for item in self {
            out.append(SubToDoItem(item:item, shouldKeepCompletion: true))
        }
        return out
    }
    
    var recreatedArrayWithoutCompletion: [SubToDoItem] {
        var out: [SubToDoItem] = []
        
        /* Recreate the whole array, to allow different items to have different sttaes for the same list */
        for item in self {
            out.append(SubToDoItem(item:item, shouldKeepCompletion: false))
        }
        return out
    }
    
    
}
