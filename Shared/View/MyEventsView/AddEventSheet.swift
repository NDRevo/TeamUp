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
                    ForEach(Games.allCases.filter({$0 != .all})){game in
                        Text(game.rawValue)
                            .tag(game)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                
                TextField("Event Location", text: $viewModel.eventLocation)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
            }

            Section {
                TextField("Event Description", text: $viewModel.eventDescription, axis: .vertical)
                    .lineLimit(4, reservesSpace: true)
            }

            Section{
                Button {
                    Task {
                        do {
                            try viewModel.createEvent(for: eventsManager)
                        } catch {
                            viewModel.isPresentingAddEvent = false
                            try await Task.sleep(nanoseconds: 50_000_000)
                            viewModel.isShowingAlert = true
                        }
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
