//
//  TimeDeltaPopup.swift
//  ToDo, Today
//
//  Created by Douglas Inglis on 05/06/2023.
//

import SwiftUI
import PopupView

struct TimeDeltaPopup: CentrePopup {
    @Binding var time: Timedelta
    
    /* Use this to make the popup update; these things don't work so well otherwise */
    @State var internalTime: Timedelta = Timedelta() {
        didSet {
            time = internalTime
        }
    }
        
    func createContent() -> some View {
        return VStack {
            
            /* Exit Button */
            ExitButtonView(dismiss: dismiss)
            
            Text("What should the time for this preset be?")
                .font(.title2)
            
            Divider()

            /* Set hours and minutes */
            TimeDeltaPickerView(time: $time, showsDays: false)
            
            /* Add done button */
            Button(action:complete, label: {
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
        .onAppear {
            internalTime = time
        }
        .onDisappear {
            complete()
        }

    }
    
    func complete() {
        /* Sort the items */
        Preferences.shared.timePresets.sort(by: {$0.time < $1.time})
        
        /* Dismiss the model */
        dismiss()
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

struct TimeDeltaPopup_Previews: PreviewProvider {
    @State static var time: Timedelta = Timedelta()
    static var previews: some View {
        TimeDeltaPopup(time: $time)
    }
}
