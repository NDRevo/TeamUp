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
            .padding(.horizontal, 12)
            .navigationTitle("Events")
            .task {
                viewModel.startUp(for: eventsManager)
                eventsManager.getPublicEvents()
            }
            .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
                viewModel.alertItem.alertMessage
            })
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
