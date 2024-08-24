//
//  RepeatUpdateBehaviour.swift
//  LifeLog
//
//  Created by Douglas Inglis on 22/05/2023.
//

import Foundation

enum RepeatUpdateBehaviour : Int32 {
    case cancel = -1
    case default_choice = 0
    case singleUpdate = 1
    case futureUpdate = 2
    case allUpdate = 3
}
