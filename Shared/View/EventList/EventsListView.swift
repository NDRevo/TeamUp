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
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 18) {
                    ForEach(eventsManager.events){ event in
                        NavigationLink {
                            EventDetailView(viewModel: EventDetailViewModel(event: event))
                        } label: {
                            EventListCell(event: event)
                        }
                    }
                }
            }
            .navigationTitle("Events")
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
            .background(Color.appBackground)
        }
    }
}

struct EventsListView_Previews: PreviewProvider {
    static var previews: some View {
        EventsListView()
            .environmentObject(EventsManager())
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
            .accessibilityLabel("Create Player")
        }
    }
}
