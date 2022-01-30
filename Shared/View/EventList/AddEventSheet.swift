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
    @Environment(\.editMode) var editMode

    var body: some View {
        List{

            Section{
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
            }

            Section {
                ZStack(alignment: .topLeading){
                    TextEditor(text: $viewModel.eventDescription)
                        .frame(height: 100)
                    if viewModel.eventDescription.isEmpty {
                        Text("Event Description")
                            .foregroundColor(.gray)
                            .opacity(0.50)
                            .offset(y: 8)
                    }
                }
            }

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
