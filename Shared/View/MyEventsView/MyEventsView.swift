//
//  MyEventsView.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 6/8/22.
//

import SwiftUI

//MARK: MyEventsView
//INFO: View to display a club leader's unpublished and published events.
//INFO: Owners can only add new events in this view
struct MyEventsView: View {

    @EnvironmentObject private var playerManager: PlayerManager
    @EnvironmentObject private var eventsManager: EventsManager
    @StateObject private var viewModel = MyEventsViewModel()

    var body: some View {
        NavigationView {
            ZStack{
                Color.appBackground.edgesIgnoringSafeArea(.all)
                if !eventsManager.myUnpublishedEvents.isEmpty || !eventsManager.myPublishedEvents.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading){
                            if !eventsManager.myUnpublishedEvents.isEmpty {
                                Text("Unpublished Events")
                                    .bold()
                                    .font(.title2)
                                VStack(spacing: 12){
                                    ForEach(eventsManager.myUnpublishedEvents) { event in
                                        NavigationLink {
                                            EventDetailView(event: event)
                                        } label: {
                                            EventListCell(event: event)
                                        }
                                    }
                                }
                            }

                            if !eventsManager.myPublishedEvents.isEmpty {
                                Text("Published Events")
                                    .bold()
                                    .font(.title2)
                                VStack(spacing: 12){
                                    ForEach(eventsManager.myPublishedEvents) { event in
                                        NavigationLink {
                                            EventDetailView(event: event)
                                        } label: {
                                            EventListCell(event: event)
                                        }
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                    }
                } else {
                    VStack(spacing: 12){
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary)
                        Text("You have no events")
                            .foregroundColor(.secondary)
                            .bold()
                    }
                    .offset(y: -90)
                }
            }
            .navigationTitle(Text("My Events"))
            .task {
                eventsManager.getMyPublishedEvents(for: playerManager.playerProfile)
                eventsManager.getMyUnpublishedEvents(for: playerManager.playerProfile)
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

struct MyEventsView_Previews: PreviewProvider {
    static var previews: some View {
        MyEventsView()
    }
}

//MARK: EventsListToolbarContent
//INFO: Refactored out ToolBarContent for create event button
struct EventsListToolbarContent: ToolbarContent {
    @ObservedObject var viewModel: MyEventsViewModel

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            NavigationLink {
               ArchivedEventsView()
            } label: {
                Image(systemName: "archivebox")
                    .tint(.blue)
            }

            Button {
                viewModel.isPresentingAddEvent = true
                viewModel.resetInput()
            } label: {
                Image(systemName: "plus.rectangle")
                    .tint(.blue)
            }
            .accessibilityLabel("Create Event")
        }
    }
}
