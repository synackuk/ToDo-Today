//
//  NotificationAddSheet.swift
//  LifeLog
//
//  Created by Douglas Inglis on 25/05/2023.
//

import SwiftUI
import PopupView

struct NotificationAddPopup: CentrePopup {
    @Environment(\.colorScheme) var colorScheme
    @Binding var notificationDate: Timedelta
    @Binding var isTimed: Bool
    
    func createContent() -> some View {
        VStack {
            
            /* Exit Button */
            ExitButtonView(dismiss: dismiss)
            
            /* Setup the start time for the notification */
            Text("How long before the start should this notification trigger?")
            TimeDeltaPickerView(time: $notificationDate, showsDays: false)
            
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
            .cornerRadius(16)
            .backgroundColour(.clear)

    }

}

struct NotificationAddPopup_Previews: PreviewProvider {
    @State static var currDate: Timedelta = Timedelta()
    @State static var isTimed = false
    static var previews: some View {
        NotificationAddPopup(notificationDate: $currDate, isTimed: $isTimed)
    }
}
