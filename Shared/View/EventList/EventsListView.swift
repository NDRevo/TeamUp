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
                    NavigationLink( destination: EventDetailView(event: event)){
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
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        viewModel.isPresentingAddEvent = true
                    } label: {
                        Image(systemName: "plus.rectangle")
                            .tint(.blue)
                    }
                }
            }
            .sheet(isPresented: $viewModel.isPresentingAddEvent){
                NavigationView {
                    AddEventSheet(viewModel: viewModel)
                        .toolbar { Button("Dismiss") { viewModel.isPresentingAddEvent = false } }
                        .navigationTitle("Create Event")
                }
            }
            .task {
                if !viewModel.onAppearHasFired {
                    viewModel.getEvents(for: eventsManager)
                    viewModel.onAppearHasFired = true
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
