//
//  DateToolbarView.swift
//  LifeLog
//
//  Created by Douglas Inglis on 04/05/2023.
//

import SwiftUI

struct DateToolbarView: View {
    @Binding var currDate: Date
    @StateObject var mainModel: ToDoViewModel = ToDoViewModel.shared
    @State private var isTargeted: Bool = false
    var body: some View {
        HStack {
            /* Left arrow to go back a week */
            Image(systemName: "arrowshape.left.fill")
                .padding(.leading, 5)
                .onTapGesture {
                    weekTransition(dir: 1)
                    
                }
                .frame(maxWidth: .infinity)
            
            /* Write out all the days of the week */
            ForEach(currDate.enumerateWeek(), id:\.self) { date in
                dayNub(date: date)
                    .onDrop(of: ["com.synackuk.LifeLog.customtype.dragdroptype"], delegate: ToDoDropDelegate(isbeingSheduled: false, startTime: date, isShowing: Binding.constant(false)))
            }
            .frame(maxWidth: .infinity)
            
            /* Right arrow to go forward a week */
            Image(systemName: "arrowshape.right.fill")
                .padding(.trailing, 5)
                .onTapGesture {
                    weekTransition(dir: -1)
                    
                }
                .frame(maxWidth: .infinity)
            
        }
        .frame(maxWidth: .infinity)
        .animation(.easeInOut, value: currDate)
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local).onEnded( { value in weekTransition(dir: value.translation.width)
        }))
    }
    
    
    func weekTransition(dir: CGFloat) {
        
        /* We set direction like this so that it matches up with the gestures width property */
        if dir > 0 {
            mainModel.currDate = currDate.prevWeek()
        }
        else if dir < 0 {
            mainModel.currDate = currDate.nextWeek()
        }
    }
    
    func dayNub(date: Date) -> some View {
        
        /* Determoine foreground and background colour */
        var foregroundColour = date.doDatesShareADay(date: Date()) ? .accentColor : Color(.label)
        var backgroundColour = Color(.systemBackground)
        
        if date.doDatesShareADay(date: currDate) {
            foregroundColour = date.doDatesShareADay(date: Date()) ? .white : Color(.systemBackground)
            backgroundColour = date.doDatesShareADay(date: Date()) ? .accentColor : Color(.label)
        }
        
        
        /* Setup VStack with our spacing */
        return VStack(spacing:5) {
            
            /* Write out the day in question (mon -> sun */
            Text(date.formatDate(formatString:"dd"))
                .font(.title2)
            
            /* Get the day of the month this date relates to */
            Text(date.formatDate(formatString:"EEE"))
                .font(.caption)
            
        }
        .foregroundColor(foregroundColour)
        .frame(maxWidth: 45, maxHeight: 75)
        .background(
            Capsule()
                .fill(backgroundColour)
        )
        .onTapGesture {
            mainModel.currDate = date
        }
    }
}

struct DateToolbarView_Previews: PreviewProvider {
    @State static var d = Date()
    static var previews: some View {
        DateToolbarView(currDate: $d)
    }
}
