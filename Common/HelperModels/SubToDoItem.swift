//
//  SubToDoItem.swift
//  ToDo, Today
//
//  Created by Douglas Inglis on 10/06/2023.
//

import Foundation

class SubToDoItem: Codable, Identifiable, Equatable {
    static func == (lhs: SubToDoItem, rhs: SubToDoItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    
    
    /* The ID For our timedelta */
    var id: UUID = UUID()
    var title: String = ""
    var completed: Bool = false
    
    
    /* Init based on another sub todo item */
    convenience init(item: SubToDoItem, shouldKeepCompletion: Bool = false) {
        self.init(title: item.title, completed: item.completed && shouldKeepCompletion)
    }
    
    /* Init with all properties prepopulated */
    init(title: String = "", completed: Bool = false) {
        id = UUID()
        self.title = title
        self.completed = completed
    }
    
    convenience init(codedString: String) {
        let decoder = JSONDecoder()
        do {
            /* Convert back to data and decode the object */
            let data = codedString.data(using: .utf8)!
            self.init(item: try decoder.decode(SubToDoItem.self, from: data), shouldKeepCompletion: true)
        }
        catch {
            self.init()
        }
    }
    
    
    func encodeToString() -> String {
        
        /* Create an encoder */
        let encoder = JSONEncoder()
        
        do {
            
            /* Encode the Timedelta */
            let retVal = try encoder.encode(self)
            
            /* Convert to string and return */
            return String(data: retVal, encoding: .utf8) ?? ""
        }
        catch {
            return ""
        }
    }

}
