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

    init() { UINavigationBar.appearance().largeTitleTextAttributes = [.font : navigationTitleFont] }

    var body: some View {
        NavigationView {
            VStack(spacing: 4) {
                ScrollView {
                    if !eventsManager.myUnpublishedEvents.isEmpty || !eventsManager.myPublishedEvents.isEmpty {
                        VStack(spacing: appHeaderToContentSpacing){
                            MyEventsListView(myEvents: eventsManager.myPublishedEvents, typeOfEvents: "Published Event")
                            MyEventsListView(myEvents: eventsManager.myUnpublishedEvents, typeOfEvents: "Unpublished Event")
                        }
                        .padding(.horizontal, appHorizontalViewPadding)
                        
                    } else {
                        HStack {
                            Spacer()
                            VStack(spacing: appImageToTextEmptyContentSpacing){
                                Image(systemName: "calendar.badge.plus")
                                    .font(.system(size: appImageSizeEmptyContent))
                                    .foregroundColor(.secondary)
                                Text("You have no events")
                                    .font(.system(.headline, design: .monospaced, weight: .medium))
                                    .foregroundColor(.secondary)
                            }
                            .offset(y: 190)
                            Spacer()
                        }
                    }
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(Text("My Events"))
            .labelsHidden()
            .background{Color.appBackground.edgesIgnoringSafeArea(.all)}
            .task {
                eventsManager.getMyPublishedEvents(for: playerManager.playerProfile)
                eventsManager.getMyUnpublishedEvents(for: playerManager.playerProfile)
            }
            .alert($viewModel.isShowingAlert, alertInfo: viewModel.alertItem)
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
            .environmentObject(PlayerManager(iCloudRecord: MockData.player, playerProfile: TUPlayer(record: MockData.player)))
            .environmentObject(EventsManager())
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

struct MyEventsListView: View {
    var myEvents: [TUEvent]
    var typeOfEvents: String
    
    var body: some View {
        if !myEvents.isEmpty {
            VStack(alignment: .leading, spacing: appHeaderToContentSpacing){
                Text(typeOfEvents)
                    .font(.system(.title2, design: .rounded, weight: .bold))
                VStack(spacing: appCellSpacing){
                    ForEach(myEvents) { event in
                        NavigationLink {
                            EventDetailView(event: event)
                        } label: {
                            EventListCell(event: event)
                        }
                    }
                }
            }
        }
    }
}
