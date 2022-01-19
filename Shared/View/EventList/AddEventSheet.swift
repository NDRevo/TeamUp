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

    var body: some View {
        List{
            TextField("Event Name", text: $viewModel.eventName)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.words)

            DatePicker("Event Date", selection: $viewModel.eventDate, in: viewModel.dateRange)

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
                    dismiss()
                    Task {
                       viewModel.createEvent(for: eventsManager)
                    }
                } label: {
                    Text("Create Event")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Create Event")
        .toolbar { Button("Dismiss") { dismiss() } }
    }
}

struct AddEventSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddEventSheet(viewModel: EventsListViewModel())
    }
}
