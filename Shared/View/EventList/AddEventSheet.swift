//
//  AddEventSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct AddEventSheet: View {
    
    @EnvironmentObject var eventsManager: EventsManager
    @ObservedObject var viewModel: EventsListViewModel

    @Environment(\.dismiss) var dismiss
    
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
            TextField("Event Name", text: $viewModel.eventName)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.words)

            DatePicker("Event Date", selection: $viewModel.eventDate, in: dateRange)

            Picker("Game", selection: $viewModel.eventGame) {
                ForEach(Games.allCases, id: \.self){game in
                    Text(game.rawValue)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            TextField("Event Location", text: $viewModel.eventLocation)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.words)
            
            Section{
                Button {
                    viewModel.createEvent(for: eventsManager)
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
        AddEventSheet(viewModel: EventsListViewModel())
    }
}
