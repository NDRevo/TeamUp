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

    @EnvironmentObject private var eventsManager: EventsManager
    @StateObject private var viewModel = EventsListViewModel()

    var body: some View {
        NavigationView {
            ZStack{
                Color.appBackground.edgesIgnoringSafeArea(.all)
                VStack {
                    GameMenuBar(viewModel: viewModel)
                    if eventsManager.events.isEmpty {NoEventsFoundMessage()}
                    else {ListOfEvents(viewModel: viewModel) }
                    Spacer()
                }
            }
            .navigationTitle("Events")
            .task {
                eventsManager.getPublicEvents(forGame: viewModel.currentGameSelected)
            }
            .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
                viewModel.alertItem.alertMessage
            })
            .alert(eventsManager.alertItem.alertTitle, isPresented: $eventsManager.isShowingAlert, actions: {}, message: {
                eventsManager.alertItem.alertMessage
            })
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
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
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
            LazyVStack(spacing: 12) {
                ForEach(eventsManager.events){ event in
                    NavigationLink {
                        EventDetailView(event: event)
                    } label: {
                        EventListCell(event: event)
                    }
                }
            }
            .padding(.horizontal, 12)
        }
    }
}

//MARK: No Events Found View
//INFO: Displays a no events found message that is non-scrollable
struct NoEventsFoundMessage: View {
    var body: some View {
        VStack(spacing: 12){
            Image(systemName: "calendar")
                .font(.system(size: 36))
                .foregroundColor(.secondary)
            Text("No events found")
                .foregroundColor(.secondary)
                .bold()
        }
        .offset(y: 120)
    }
}
