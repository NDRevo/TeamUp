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
                        viewModel.deleteEvent(eventID: recordID)

                        eventsManager.events.remove(at: index)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Events")
            .refreshable {
                viewModel.refresh(for: eventsManager)
            }
            .task {
                viewModel.startUp(for: eventsManager)
            }
            .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
                viewModel.alertItem.alertMessage
            })
            .toolbar {
                EventsListToolbarContent(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.isPresentingAddEvent) {
                NavigationView {
                    AddEventSheet(viewModel: viewModel)
                }
            }
        }
    }
}

struct EventsListView_Previews: PreviewProvider {
    static var previews: some View {
        EventsListView()
    }
}

struct EventsListToolbarContent: ToolbarContent {
    @ObservedObject var viewModel: EventsListViewModel

    var body: some ToolbarContent {
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
}
