//
//  AddEventSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

private enum Field: Int, CaseIterable {
    case eventName,eventGameName, eventIRLLocation, eventDiscordLocation, eventDescription
}

public enum Locations: String, CaseIterable {
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
                    .font(.system(.body, design: .rounded, weight: .regular))
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .onChange(of: viewModel.eventName) { _ in
                        viewModel.eventName = String(viewModel.eventName.prefix(25))
                    }
                    .focused($focusField, equals: .eventName)

                Picker("Game", selection: $viewModel.eventGame) {
                    //Starts from 2 to remove "All" & other case
                    ForEach(GameLibrary.data.games[1...]){game in
                        Text(game.name)
                            .tag(game.self)
                    }
                }
                .pickerStyle(.menu)
                .font(.system(.body, design: .monospaced, weight: .medium))

                if !viewModel.eventGame.gameVariants.isEmpty {
                        Picker("Variant", selection: $viewModel.eventGameVariant) {
                            ForEach(viewModel.eventGame.gameVariants){game in
                                Text(game.name)
                                    .tag(game.self)
                            }
                        }
                        .pickerStyle(.menu)
                        .font(.system(.body, design: .monospaced, weight: .medium))
                }

                if viewModel.eventGame.name == GameNames.other {
                    TextField("Game Name", text: $viewModel.userInputEventGameName)
                        .focused($focusField, equals: .eventGameName)
                        .font(.system(.body, design: .rounded, weight: .regular))
                }

                DatePicker("Start Date", selection: $viewModel.eventDate, in: viewModel.dateRange)
                    .font(.system(.body, design: .monospaced, weight: .medium))
                DatePicker("End Date", selection: $viewModel.eventEndDate, in: viewModel.dateRange)
                    .font(.system(.body, design: .monospaced, weight: .medium))
                    .onChange(of: viewModel.eventDate) { newValue in
                        if viewModel.eventEndDate <= newValue {
                            viewModel.eventEndDate = Calendar.current.date(byAdding: .hour, value: 1, to: newValue)!
                        }
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
                        .font(.system(.body, design: .monospaced, weight: .medium))
                })
                .onChange(of: viewModel.locationPicked) { _ in
                    viewModel.eventLocation = ""
                }
                if viewModel.locationPicked == .discord {
                    HStack(spacing:0){
                        Text("\(WordConstants.discordgg)/")
                            .bold()
                        TextField(text: $viewModel.eventLocation) {
                            Text("valowatch")
                        }
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($focusField, equals: .eventDiscordLocation)
                    }
                    .font(.system(.body, design: .monospaced, weight: .medium))
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
                        .font(.system(.body, design: .rounded, weight: .regular))
                        .focused($focusField, equals: .eventIRLLocation)
                        .textInputAutocapitalization(.words)
                    }
                }
            }
            .listSectionSeparator(.hidden)
            
            
            Section {
                TextField("Event Description", text: $viewModel.eventDescription, axis: .vertical)
                    .font(.system(.body, design: .rounded, weight: .regular))
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
            SearchMapView(eventLocationTitle: $viewModel.eventLocationTitle, eventLocation: $viewModel.eventLocation)
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
