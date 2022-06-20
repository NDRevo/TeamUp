//
//  MyEventsView.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 6/8/22.
//

import SwiftUI

struct MyEventsView: View {

    @StateObject private var viewModel = MyEventsViewModel()
    @EnvironmentObject private var eventsManager: EventsManager

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading){
                    if !eventsManager.myUnpublishedEvents.isEmpty {
                        Text("Unpublished Events")
                            .bold()
                            .font(.title2)
                            .padding(.horizontal)
                        ForEach(eventsManager.myUnpublishedEvents) { event in
                            NavigationLink {
                                EventDetailView(viewModel: EventDetailViewModel(event: event))
                            } label: {
                                EventListCell(event: event)
                            }
                        }
                    }
                    
                    if !eventsManager.myPublishedEvents.isEmpty {
                        Text("Published Events")
                            .bold()
                            .font(.title2)
                            .padding(.horizontal)
                        ForEach(eventsManager.myPublishedEvents) { event in
                            NavigationLink {
                                EventDetailView(viewModel: EventDetailViewModel(event: event))
                            } label: {
                                EventListCell(event: event)
                            }
                        }
                    }
                    Spacer()
                }
            }
            .navigationTitle(Text("My Events"))
            .task {
                eventsManager.getMyPublishedEvents()
                eventsManager.getMyUnpublishedEvents()
            }
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

struct MyEventsView_Previews: PreviewProvider {
    static var previews: some View {
        MyEventsView()
    }
}

struct EventsListToolbarContent: ToolbarContent {
    @ObservedObject var viewModel: MyEventsViewModel

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
