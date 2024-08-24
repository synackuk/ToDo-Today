//
//  IconChooserSheet.swift
//  LifeLog
//
//  Created by Douglas Inglis on 03/05/2023.
//

import SwiftUI

struct IconChooserSheet: View {
    @Environment(\.dismiss) var dismiss
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var chosenIcon: String
    @State var chosenColour: Color = .blue
    @State var searchString: String = ""
    
    /* List of all icons */
    private let icons = ["calendar", "drop.fill", "figure.walk", "figure.run", "graduationcap.fill", "clock.fill", "building.fill", "bed.double.fill", "moon.fill", "x.squareroot", "rectangle.portrait.and.arrow.right.fill", "pencil", "pencil.line", "eraser.fill", "square.and.pencil", "scribble.variable", "trash.fill", "folder.fill", "paperplane.fill", "tray.fill", "tray.full.fill", "doc.fill", "clipboard.fill", "list.clipboard.fill", "terminal.fill", "note.text", "book.fill", "books.vertical.fill", "book.closed.fill", "menucard.fill", "newspaper.fill", "pencil.and.ruler.fill", "backpack.fill", "studentdesk", "person.fill", "lanyardcard.fill", "person.text.rectangle.fill", "figure.badminton", "tennis.racket", "football.fill", "basketball.fill", "soccerball", "trophy.fill", "keyboard.fill", "globe", "sun.max.fill", "sunset.fill", "sun.and.horizon.fill", "moon.haze.fill", "moon.zzz.fill", "moon.stars.fill", "cloud.fill", "cloud.drizzle.fill", "snowflake", "tornado", "flame.fill", "umbrella.fill", "play.fill", "playpause", "infinity", "sos", "megaphone.fill", "speaker.fill", "music.note", "music.mic", "music.note.list", "mic.fill", "heart.fill", "bell.fill", "bolt.fill", "tag.fill", "flashlight.on.fill", "camera.fill", "message.fill", "phone.fill", "video.fill", "envelope.fill", "mail.stack.fill", "gear", "scissors", "cart.fill", "basket.fill", "creditcard.fill", "giftcard.fill", "wallet.pass.fill", "tuningfork", "paintbrush.fill", "level.fill", "screwdriver.fill", "wrench.and.screwdriver.fill", "stethoscope", "printer.fill", "case.fill", "briefcase.fill", "house.fill", "lightbulb.fill", "dehumidifier.fill", "air.purifier.fill", "spigot.fill", "bathtub.fill", "wifi.router.fill", "balloon.fill", "party.popper.fill", "sofa.fill", "chair.lounge.fill", "refrigerator.fill", "sink.fill", "toilet.fill", "tent.fill", "mountain.2.fill", "lock.fill", "key.fill", "map.fill", "move.3d", "cpu.fill", "desktopcomputer", "server.rack", "candybarphone", "apps.iphone", "computermouse.fill", "earbuds.case.fill", "earbuds", "hifispeaker.2.fill", "av.remote.fill", "tv.inset.filled", "radio.fill", "airplane", "guitars.fill", "bolt.car.fill", "bus", "tram", "cablecar", "ferry.fill", "train.side.front.car", "bicycle", "fuelpump.fill", "engine.combustion.fill", "oilcan.fill", "syringe.fill", "pill.fill", "pills.fill", "cross.fill", "testtube.2", "hare.fill", "bird.fill", "leaf.fill", "camera.macro", "tree.fill", "tshirt.fill", "film.fill", "ticket.fill", "eye", "camera.aperture", "flowchart", "shippingbox.fill", "alarm.fill", "deskclock.fill", "gamecontroller.fill", "cup.and.saucer.fill", "mug.fill", "takeoutbag.and.cup.and.straw.fill", "wineglass.fill", "carrot.fill", "fork.knife", "chart.bar.fill", "chart.pie.fill", "waveform.path.ecg", "simcard.2.fill", "gift.fill", "hourglass", "banknote.fill", "chevron.left.forwardslash.chevron.right", "dollarsign", "sterlingsign", "volume.1.fill", "dumbbell.fill", "car.fill", "network", "birthday.cake.fill", "questionmark.circle.fill"]
    
    var body: some View {
        VStack {
            
            ExitButtonView(dismiss: dismiss.callAsFunction)
            
            
            /* Search Field */
            TextField("Search", text: $searchString)
                .padding()
                .frame(height: 55)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(12)
                .padding()
            
            ScrollView {
                
                /* Grid of icons */
                LazyVGrid(columns: [GridItem(.adaptive(minimum:75))]) {
                    
                    ForEach(icons, id:\.self) { icon in
                        
                        if searchString == "" || icon.contains(searchString.lowercased()) {
                            
                            ZStack {
                                
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(.systemFill))
                                    .frame(width:70, height:70)
                                
                                Image(systemName: icon)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width:45, height:45)
                                    .foregroundColor((icon == chosenIcon) ? chosenColour : Color(.label))
                                
                                
                            }
                            .padding(.horizontal)
                            .onTapGesture {
                                chosenIcon = icon
                            }
                        }
                    }
                    .padding(.horizontal)
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
        }
    }
}

struct IconChooserSheet_Previews: PreviewProvider {
    @State static var chosen: String = "drop.fill"
    static var previews: some View {
        IconChooserSheet(chosenIcon: $chosen, chosenColour:.blue)
    }
}
