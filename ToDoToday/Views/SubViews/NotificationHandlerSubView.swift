//
//  NotificationHandlerSubView.swift
//  LifeLog
//
//  Created by Douglas Inglis on 25/05/2023.
//

import SwiftUI
import PopupView


struct NotificationHandlerSubView: View {
    @Binding var notificationDates: [Timedelta]
    @Binding var isTimed: Bool
    @StateObject private var purchasePrefs = PurchasePreferences.shared
    @State private var showingBuyOption = false
    var body: some View {
        VStack {
            
            /* New notification button */
            Button(action:{
                if purchasePrefs.isProUser {
                    notificationDates.append(Timedelta())
                }
                else {
                    showingBuyOption = true
                }
                }) {
                HStack {
                    
                    Text("Add new notification")
                        .font(.headline)
                        .foregroundColor(Color(.label))
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    PlusButton()
                    
                    
                }
                .padding(10)
            }
            .frame(height:55)
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
    
            /* Foreach notification */
            ForEach(notificationDates) { date in
                
                /* Get the index for this date */
                let index = notificationDates.firstIndex(of: date)!
                
                Button(action:{
                    NotificationAddPopup(notificationDate: $notificationDates[index], isTimed: $isTimed).showAndStack()
                }) {
                    HStack {
                        
                        /* Pretty icon */
                        Image(systemName: "bell.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(Color(.label))
                            .frame(width:20, height:20).padding(.leading)
                        
                        /* Text view, based on the notification */
                        Text(date.timeString(defaultString: "Start of event"))
                            .font(.subheadline)
                            .foregroundColor(Color(.label))
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                        /* Delete button */
                        DeleteButton()
                            .onTapGesture {
                                notificationDates.remove(at: index)
                            }
                        
                        
                    }
                }
                .frame(height:30)
                .padding(5)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)

            }
        
        }
        .sheet(isPresented: $showingBuyOption) {
            BuyProSheet()
        }

    }
}

struct NotificationHandlerSubView_Previews: PreviewProvider {
    @State static var dates: [Timedelta] = [Timedelta(timeDelta: 0), Timedelta(timeDelta: 10)]
    @State static var isTimed = false
    static var previews: some View {
        NotificationHandlerSubView(notificationDates: $dates, isTimed: $isTimed)
    }
}
