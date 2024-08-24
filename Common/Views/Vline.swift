//
//  Vline.swift
//  LifeLog
//
//  Created by Douglas Inglis on 28/05/2023.
//

import SwiftUI

struct VLine: Shape {
    
    /* Create a line we can stroke */
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        return path
    }
}
