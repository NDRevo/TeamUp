//
//  EventsListView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import SwiftUI

struct EventsListView: View {
    
    @EnvironmentObject private var eventsManager: EventsManager
    @StateObject private var viewModel = EventsListViewModel()
    
    var body: some View {
        NavigationView{
            List {
                ForEach(eventsManager.events){ event in
                    NavigationLink( destination: EventDetailView(viewModel: EventDetailViewModel(event: event))){
                        EventListCell(event: event)
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let recordID = eventsManager.events[index].id
                        viewModel.deleteEvent(recordID: recordID)

                        eventsManager.events.remove(at: index)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Events")
            .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
                viewModel.alertItem.alertMessage
            })
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        viewModel.isPresentingAddEvent = true
                        viewModel.resetInput()
                    } label: {
                        Image(systemName: "plus.rectangle")
                            .tint(.blue)
                    }
                }
            }
            .sheet(isPresented: $viewModel.isPresentingAddEvent, onDismiss: {
                if viewModel.createEventButtonPressed{
                    viewModel.createEvent(for: eventsManager)
                    viewModel.createEventButtonPressed = false
                }
            },content: {
                NavigationView {
                    AddEventSheet(viewModel: viewModel)
                }
            })
            .task {
                viewModel.getEvents(for: eventsManager)
            }
        }
    }
}

struct EventsListView_Previews: PreviewProvider {
    static var previews: some View {
        EventsListView()
    }
}
