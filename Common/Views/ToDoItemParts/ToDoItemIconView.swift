//
//  ToDoItemIconView.swift
//  ToDo, Today
//
//  Created by Douglas Inglis on 13/06/2023.
//

import SwiftUI

struct ToDoItemIconView: View {
    @StateObject private var currTimeModal: CurrTimeModel = CurrTimeModel.shared

    @ObservedObject var model: ToDoModel
    
    @State var frameWidth: CGFloat = 60
    
    @State var circularFrame: Bool = false
    
    #if os(watchOS)
    @State private var bgColour = Color(white: 0.19)
    #else
    @State private var bgColour = Color(.secondarySystemBackground)
    #endif
    
    var body: some View {
        ZStack(alignment: .leading) {
            GeometryReader { geo in
                /* Overlay the iconFrames, with the front one depending on the progress through the task */
                iconFrame(foregroundColour: model.toDoColour, backgroundColour: bgColour, circularFrame:circularFrame)
                    .frame(maxHeight: .infinity)
                iconFrame(foregroundColour: model.toDoColour.getContrastingColour(), backgroundColour: model.toDoColour, circularFrame:circularFrame)
                    .frame(maxHeight: .infinity)
                    .mask {
                        iconMask(inHeight: geo.size.height)
                        Spacer(minLength: 0)
                    }
            }
        }
    }
    func iconFrame(foregroundColour: Color, backgroundColour: Color, circularFrame: Bool) -> some View {
        return ZStack {
            if !circularFrame {
                Capsule()
                    .fill(backgroundColour)
                    .frame(width: frameWidth)
            }
            else {
                Circle()
                    .fill(backgroundColour)
                    .frame(width: frameWidth)

            }
            Image(systemName: model.icon)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(foregroundColour)
                .frame(width: frameWidth * 2/3, height: frameWidth * 2/3)
        }
    }
    
    func iconMask(inHeight: CGFloat) -> some View {
        var height = inHeight
        if model.timeSheduled {
            height *= model.startDate.getPercentTimePassed(endDate: model.endDate, nowDate: currTimeModal.currTime)
        }
        return Rectangle()
            .frame(width: frameWidth, height: height)
    }
}

struct ToDoItemIconView_Previews: PreviewProvider {
    @StateObject static var model = ToDoModel()
    static var previews: some View {
        ToDoItemIconView(model: model)
    }
}
