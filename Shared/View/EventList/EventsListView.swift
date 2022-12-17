//
//  EventsListView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import SwiftUI

//MARK: EventsListView
//INFO: First tab displayed to user. Shows list of events for all games or a specific game
struct EventsListView: View {

    @EnvironmentObject private var playerManager: PlayerManager
    @EnvironmentObject private var eventsManager: EventsManager
    @StateObject private var viewModel = EventsListViewModel()

    init() { UINavigationBar.appearance().largeTitleTextAttributes = [.font : navigationTitleFont] }

    var body: some View {
        NavigationView {
            VStack{
                GameMenuBar(viewModel: viewModel)
                if eventsManager.events.isEmpty {NoEventsFoundMessage()}
                else {ListOfEvents(viewModel: viewModel)}
                Spacer()
            }
            .background{Color.appBackground.edgesIgnoringSafeArea(.all)}
            .refreshable {
                eventsManager.getPublicEvents(forGame: viewModel.currentGameSelected)
                guard let _ = playerManager.playerProfile else {
                    Task{await playerManager.getRecordAndPlayerProfile()}
                    return
                }
            }
            .navigationTitle("Events")
            .onAppear {
                eventsManager.getPublicEvents(forGame: viewModel.currentGameSelected)
                Task {
                    await eventsManager.archiveEvents()
                }
            }
            .alert($viewModel.isShowingAlert, alertInfo: viewModel.alertItem)
            .alert($eventsManager.isShowingAlert, alertInfo: eventsManager.alertItem)
        }
    }
}

struct EventsListView_Previews: PreviewProvider {
    static var previews: some View {
        EventsListView()
            .environmentObject(EventsManager())
    }
}

//MARK: Game Menu Bar
//INFO: Displays game cells you can tap to filter specific events based on game
struct GameMenuBar: View {
    @ObservedObject var viewModel: EventsListViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack{
                ForEach(GameLibrary.data.games) { game in
                    MenuBarGameCell(viewModel: viewModel, game: game)
                }
            }
            .padding(4)
        }
    }
}

//MARK: List Of Events View
//INFO: Displays lists of events that are tappable to view more details
struct ListOfEvents: View {
    @EnvironmentObject var eventsManager: EventsManager
    @ObservedObject var viewModel: EventsListViewModel

    var body: some View {
        ScrollView {
            LazyVStack(spacing: appCellSpacing) {
                ForEach(eventsManager.events){ event in
                    NavigationLink {
                        EventDetailView(event: event)
                    } label: {
                        EventListCell(event: event)
                    }
                }
            }
            .padding(.horizontal, appHorizontalViewPadding)
        }
    }
}

//MARK: No Events Found View
//INFO: Displays a no events found message that is non-scrollable
struct NoEventsFoundMessage: View {
    var body: some View {
        ScrollView {
            VStack(spacing: appImageToTextEmptyContentSpacing){
                Image(systemName: "calendar")
                    .font(.system(size: appImageSizeEmptyContent))
                    .foregroundColor(.secondary)
                Text("No events found")
                    .font(.system(.headline, design: .monospaced, weight: .medium))
                    .foregroundColor(.secondary)
            }
            .offset(y: 120)
        }
    }
}
