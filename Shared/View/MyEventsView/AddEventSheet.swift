//
//  AddEventSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct AddEventSheet: View {

    @EnvironmentObject var eventsManager: EventsManager
    @ObservedObject var viewModel: MyEventsViewModel

    var body: some View {
        List{

            Section{
                TextField("Event Name", text: $viewModel.eventName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)

                DatePicker("Event Date", selection: $viewModel.eventDate, in: viewModel.dateRange)
                DatePicker("Event End Date", selection: $viewModel.eventEndDate, in: viewModel.dateRange)
                    .onChange(of: viewModel.eventDate) { newValue in
                        if viewModel.eventEndDate <= newValue {
                            viewModel.eventEndDate = Calendar.current.date(byAdding: .hour, value: 1, to: newValue)!
                        }
                    }

                Picker("Game", selection: $viewModel.eventGame) {
                    //TIP: Starts from 1 to remove "All" case
                    ForEach(GameLibrary.data.games[1...]){game in
                        Text(game.name)
                            .tag(game.self)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                if !viewModel.eventGame.gameVariants.isEmpty {
                        Picker("Variant", selection: $viewModel.eventGameVariant) {
                            ForEach(viewModel.eventGame.gameVariants){game in
                                Text(game.name)
                                    .tag(game.self)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                }

                TextField("Event Location", text: $viewModel.eventLocation)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .foregroundColor(viewModel.isDiscordLink ? .blue : .none)
                    .onChange(of: viewModel.eventLocation) { text in
                        if text.starts(with: "discord.gg"){
                            viewModel.isDiscordLink = true
                        }
                    }
            }

            Section {
                TextField("Event Description", text: $viewModel.eventDescription, axis: .vertical)
                    .lineLimit(4, reservesSpace: true)
            }

            Section{
                Button {
                    Task {
                        try viewModel.createEvent(for: eventsManager)
                        viewModel.isPresentingAddEvent = false
                    }
                } label: {
                    Text("Create Event")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Create Event")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                //TIP: Publishing changes from within view updates is not allowed, this will cause undefined behavior.
                Button("Cancel") {viewModel.isPresentingAddEvent = false}
            }
        }
        //TIP: Adding alert doesn't allow cancel button / dismissmal of sheet to work
    }
}

struct AddEventSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddEventSheet(viewModel: MyEventsViewModel())
    }
}
