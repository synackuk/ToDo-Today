//
//  CircularProgressIndicator.swift
//  LifeLog
//
//  Created by Douglas Inglis on 30/04/2023.
//

import SwiftUI

struct CircularProgressIndicator: View {
    @ObservedObject var model: ToDoModel
    var shouldShowCheck: Bool = true
    var body: some View {
        GeometryReader{
            metrics in
            ZStack {
                let lineWidth = min(metrics.size.width * 0.1, 5)
                /* Background circle, has half opacity to differentiate it from the progress circle */
                Circle()
                    .stroke(model.toDoColour.opacity(0.5), lineWidth: lineWidth)
                
                /* The ring that fills up the circle as progress is made. Capped at 100% progress */
                RingShape(percent: min(model.decimalProgress, 1.0))
                    .stroke(model.toDoColour, style:
                                StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .animation(.easeInOut, value: model.decimalProgress)
                
                /* Circle that draws our shadow, this allows us to handle progress >100% */
                Circle()
                
                /* Fill as this is hidden by the mask, note that this circle is invisible when progress == 0 */
                    .fill((model.decimalProgress > 0) ? model.toDoColour : .clear)
                    .shadow(color: .black, radius: 2, x:2, y:0)
                    .mask {
                        
                        /* Mask with a rectangle that splits the circle in half, this hides shadow going in any wrong directions */
                        Rectangle().frame(width:4*lineWidth).offset(x:2*lineWidth)
                    }
                    .frame(width:lineWidth)
                
                /* Place the circle at the top of our outer circle */
                    .offset(x:0, y:-metrics.size.width/2)
                
                /* Rotate it round the circle to the correct location */
                    .rotationEffect(.radians(NSDecimalNumber(decimal: model.decimalProgress).doubleValue * 2 * .pi))
                    .animation(.easeInOut, value: model.decimalProgress)
                
                
                /* If the progress is not one then provide the progress text */
                if shouldShowCheck {
                    if(model.decimalProgress != 1) {
                        Text(model.completionText)
                            .font(.system(size: 500).monospaced())
                            .minimumScaleFactor(0.0001)
                            .lineLimit(1)
                            .frame(width: metrics.size.width / 1.2, height: metrics.size.width / 1.2)
                        
                    }
                    /* Otherwise display a 'completed' checkmark */
                    else {
                        Image(systemName: "checkmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: metrics.size.width / 2, height: metrics.size.width / 2)
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
    }
}
struct CircularProgressIndicator_Previews: PreviewProvider {
    @StateObject static var model = ToDoModel()
    static var previews: some View {
        CircularProgressIndicator(model: model)
    }
}
