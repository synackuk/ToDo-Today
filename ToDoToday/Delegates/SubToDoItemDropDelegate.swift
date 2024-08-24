//
//  SubToDoItemDropDelegate.swift
//  LifeLog
//
//  Created by Douglas Inglis on 30/05/2023.
//

import Foundation
import SwiftUI

struct SubToDoItemDropDelegate: DropDelegate {
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    /* Trivial delegatem just sets the operation to move. */
    func performDrop(info: DropInfo) -> Bool {
        return true
    }
}
