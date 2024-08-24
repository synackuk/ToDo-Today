//
//  DatePickerSheet.swift
//  LifeLog
//
//  Created by Douglas Inglis on 21/05/2023.
//

import SwiftUI
import PopupView

struct DatePickerPopup: CentrePopup {
    @Binding var currDate: Date
    func createContent() -> some View {
        VStack {
            
            /* Exit Button */
            ExitButtonView(dismiss: dismiss)
            
            /* Just a date picker, to allow you to choose the new date */
            DatePicker("Select the date to display", selection: $currDate, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .padding()
                .frame(maxWidth: .infinity)
            
            Button(action:dismiss, label: {
                Text("Done")
                    .font(.title3)
                    .foregroundColor(Color(.white))
                    .frame(maxWidth: .infinity, alignment: .center)
            })
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.accentColor)
            .cornerRadius(12)
            .padding()

        }
        .frame(maxWidth:480)
        .background(Color(.secondarySystemBackground).cornerRadius(20))

    }
    func configurePopup(popup: CentrePopupConfig) -> CentrePopupConfig {
        popup
        #if targetEnvironment(macCatalyst)
            .tapOutsideToDismiss(false)
        #endif
            .horizontalPadding(20)
            .backgroundColour(.clear)
            .cornerRadius(16)
    }
}

struct DatePickerSheet_Previews: PreviewProvider {
    @State static var currDate: Date = Date()
    static var previews: some View {
        DatePickerPopup(currDate: $currDate)
    }
}
