//
//  CurrTimeModel.swift
//  LifeLog
//
//  Created by Douglas Inglis on 04/05/2023.
//

import Foundation

class CurrTimeModel : ObservableObject {
    static var shared = CurrTimeModel(shouldUpdate: true)
    var shouldUpdate: Bool
    var currTime: Date = Date() {
        didSet {
            if shouldUpdate {
                objectWillChange.send()
            }
        }
    }
    private var timer: Timer?
    
    init(shouldUpdate: Bool) {
        self.shouldUpdate = shouldUpdate
        start()
    }
    
    func start() {
        /* Every second update the current date */
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.currTime = Date()
            
        })
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
    }
    
    deinit {
        timer?.invalidate()
    }
}
