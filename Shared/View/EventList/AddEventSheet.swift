//
//  AddEventSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct AddEventSheet: View {
    
    @EnvironmentObject var eventsManager: EventsManager
    @Environment(\.dismiss) var dismiss
    let games = ["VALORANT", "Apex", "Fortnite"]
    @State var eventName: String = ""
    @State var eventGame: Games
    @State var eventDate: Date = Date()
    
    let dateRange: PartialRangeFrom<Date> = {
        let date = Date()
        let calendar = Calendar.current
        let startDate = DateComponents(
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date)
        )
        return calendar.date(from:startDate)!...
    }()
    
    var body: some View {
        List{
            Picker("Game", selection: $eventGame) {
                ForEach(Games.allCases, id: \.self){game in
                    Text(game.rawValue)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            TextField("Event Name", text: $eventName)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.words)

            DatePicker("Event Date", selection: $eventDate, in: dateRange)
            
            Section{
                Button {
                    eventsManager.events.append(TUEvent(date: eventDate, name: eventName, game: eventGame))
                    dismiss()
                } label: {
                    Text("Create Event")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct AddEventSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddEventSheet(eventGame: Games.VALORANT)
    }
}
