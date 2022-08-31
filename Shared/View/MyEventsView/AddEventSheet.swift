//
//  AddEventSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI
//MARK: AddEventSheet
//INFO: Sheet displayed to add an event. Is set to unpublished by default
//INFO: Add Event: Name, Start Date, End Date, Game, Game Variant, Location, and Description
struct AddEventSheet: View {

    @EnvironmentObject var eventsManager: EventsManager
    @ObservedObject var viewModel: MyEventsViewModel

    var body: some View {
        List{

            Section{
                TextField("Event Name", text: $viewModel.eventName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .onChange(of: viewModel.eventName) { _ in
                        viewModel.eventName = String(viewModel.eventName.prefix(25))
                    }

                DatePicker("Event Date", selection: $viewModel.eventDate, in: viewModel.dateRange)
                DatePicker("Event End Date", selection: $viewModel.eventEndDate, in: viewModel.dateRange)
                    .onChange(of: viewModel.eventDate) { newValue in
                        if viewModel.eventEndDate <= newValue {
                            viewModel.eventEndDate = Calendar.current.date(byAdding: .hour, value: 1, to: newValue)!
                        }
                    }

                Picker("Game", selection: $viewModel.eventGame) {
                    //Starts from 1 to remove "All" case
                    ForEach(GameLibrary.data.games[2...]){game in
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
                    .onChange(of: viewModel.eventLocation) { _ in
                        viewModel.eventLocation = String(viewModel.eventLocation.prefix(100))
                    }
            }

            Section {
                TextField("Event Description", text: $viewModel.eventDescription, axis: .vertical)
                    .lineLimit(10, reservesSpace: true)
                    .onChange(of: viewModel.eventDescription) { _ in
                        viewModel.eventDescription = String(viewModel.eventDescription.prefix(350))
                    }
            } footer: {
                Text("\(350 - viewModel.eventDescription.count) characters left.")
            }

            Section{
                Button {
                    Task {
                        try viewModel.createEvent(for: eventsManager)
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
                //MARK: Publishing changes from within view updates is not allowed, this will cause undefined behavior.
                Button("Cancel") {viewModel.isPresentingAddEvent = false}
            }
        }
        .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
            viewModel.alertItem.alertMessage
        })
    }
}

struct AddEventSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddEventSheet(viewModel: MyEventsViewModel())
    }
}
