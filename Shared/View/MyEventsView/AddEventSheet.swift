//
//  AddEventSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

private enum Field: Int, CaseIterable {
    case eventName, eventIRLLocation, eventDiscordLocation, eventDescription
}

public enum locations: String, CaseIterable {
    case irl = "IRL"
    case discord = "Discord"
}

//MARK: AddEventSheet
//INFO: Sheet displayed to add an event. Is set to unpublished by default
//INFO: Add Event: Name, Start Date, End Date, Game, Game Variant, Location, and Description
struct AddEventSheet: View {

    @EnvironmentObject var playerManager: PlayerManager
    @EnvironmentObject var eventsManager: EventsManager
    @ObservedObject var viewModel: MyEventsViewModel
    @FocusState private var focusField: Field?

    var body: some View {
        List{
            Section{
                TextField("Event Name", text: $viewModel.eventName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .onChange(of: viewModel.eventName) { _ in
                        viewModel.eventName = String(viewModel.eventName.prefix(25))
                    }
                    .focused($focusField, equals: .eventName)

                Picker("Game", selection: $viewModel.eventGame) {
                    //Starts from 2 to remove "All" & other case
                    ForEach(GameLibrary.data.games[2...]){game in
                        Text(game.name)
                            .tag(game.self)
                    }
                }
                .pickerStyle(.menu)

                DatePicker("Event Date", selection: $viewModel.eventDate, in: viewModel.dateRange)
                DatePicker("Event End Date", selection: $viewModel.eventEndDate, in: viewModel.dateRange)
                    .onChange(of: viewModel.eventDate) { newValue in
                        if viewModel.eventEndDate <= newValue {
                            viewModel.eventEndDate = Calendar.current.date(byAdding: .hour, value: 1, to: newValue)!
                        }
                    }

                if !viewModel.eventGame.gameVariants.isEmpty {
                        Picker("Variant", selection: $viewModel.eventGameVariant) {
                            ForEach(viewModel.eventGame.gameVariants){game in
                                Text(game.name)
                                    .tag(game.self)
                            }
                        }
                        .pickerStyle(.menu)
                }
            }

            Section {
                Picker(selection: $viewModel.locationPicked, content: {
                    ForEach(viewModel.locations, id: \.self){ location in
                        Button {
                            viewModel.locationPicked = location
                        } label: {
                            Text(location.rawValue)
                        }
                    }
                }, label: {
                    Text("Location Type")
                })
                .onChange(of: viewModel.locationPicked) { _ in
                    viewModel.eventLocation = ""
                }
                if viewModel.locationPicked == .discord {
                    HStack(spacing:0){
                        Text("discord.gg/")
                            .bold()
                        TextField(text: $viewModel.eventLocation) {
                            Text("valowatch")
                        }
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($focusField, equals: .eventDiscordLocation)
                    }
                } else {
                    HStack{
                        Image(systemName: "magnifyingglass")
                            .onTapGesture {
                                viewModel.isPresentingMap = true
                            }
                            .foregroundColor(.blue)
                        TextField(text: $viewModel.eventLocation) {
                            Text("Event Location")
                        }
                        .focused($focusField, equals: .eventIRLLocation)
                        .textInputAutocapitalization(.words)
                    }
                }
            }
            .listSectionSeparator(.hidden)
            
            
            Section {
                TextField("Event Description", text: $viewModel.eventDescription, axis: .vertical)
                    .lineLimit(10, reservesSpace: true)
                    .onChange(of: viewModel.eventDescription) { _ in
                        viewModel.eventDescription = String(viewModel.eventDescription.prefix(350))
                    }
                    .focused($focusField, equals: .eventDescription)
            } footer: {
                Text("\(350 - viewModel.eventDescription.count) characters left.")
            }

            Section{
                Button {
                    Task {
                        try viewModel.createEvent(for: eventsManager, from: playerManager.playerProfile?.record, with: playerManager.playerProfile)
                    }
                } label: {
                    Text("Create Event")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Create Event")
        .sheet(isPresented: $viewModel.isPresentingMap, content: {
            SearchMapView(viewModel: viewModel)
        })
        .scrollIndicators(.hidden)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                //MARK: Publishing changes from within view updates is not allowed, this will cause undefined behavior.
                Button("Cancel") {viewModel.isPresentingAddEvent = false}
            }

            ToolbarItemGroup(placement: .keyboard) {
                Button {
                    focusField = nil
                } label: {
                    Image(systemName: "keyboard.badge.eye.fill")
                }
            }
        }
        .alert($viewModel.isShowingAlert, alertInfo: viewModel.alertItem)
    }
}

struct AddEventSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddEventSheet(viewModel: MyEventsViewModel())
    }
}
