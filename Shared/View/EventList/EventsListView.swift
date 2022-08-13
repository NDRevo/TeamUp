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
            ZStack{
                Color.appBackground.edgesIgnoringSafeArea(.all)
                VStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack{
                            ForEach(GameLibrary.data.games) { game in
                                GameCell(viewModel: viewModel, game: game)
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                    }

                    if eventsManager.events.isEmpty {
                        VStack(spacing: 12){
                            Image(systemName: "calendar")
                                .font(.system(size: 36))
                                .foregroundColor(.secondary)
                            Text("No events found")
                                .foregroundColor(.secondary)
                                .bold()
                        }
                        .offset(y: 120)
                    } else {
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
        }
    }
}

struct EventsListView_Previews: PreviewProvider {
    static var previews: some View {
        EventsListView()
            .environmentObject(EventsManager())
    }
}
