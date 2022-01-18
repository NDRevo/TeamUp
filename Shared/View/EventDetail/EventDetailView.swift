//
//  EventDetailView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/12/22.
//

import SwiftUI

struct EventDetailView: View {

    @EnvironmentObject var manager: EventsManager
    @StateObject var eventManager = EventDetailViewModel()
    var event: TUEvent

    var body: some View {
        List {
            Section(header: Text("Matches")) {
                ForEach(eventManager.matches) { match in
                    NavigationLink(destination: MatchDetailView(viewModel: MatchDetailViewModel(match: match, playersInEvent: eventManager.playersInEvent))) {
                        VStack(alignment: .leading){
                            Text(match.matchName)
                            Text(match.matchStartTime.convertDateToString())
                                .font(.caption)
                        }
                    }
                }
                .onDelete { indexSet in
                    for index in indexSet {
                        let recordID = eventManager.matches[index].id
                        eventManager.deleteMatch(recordID: recordID)
                        eventManager.matches.remove(at: index)
                    }
                }
                Button {
                    eventManager.isShowingAddMatch = true
                    eventManager.resetMatchInput()
                } label: {
                    Text("Add Match")
                        .foregroundColor(.blue)
                }
            }
            .sheet(isPresented: $eventManager.isShowingAddMatch){
                NavigationView{
                    AddMatchSheet(viewModel: eventManager)
                }
            }
    
            Section(header: Text("Players")) {
                ForEach(eventManager.playersInEvent){ player in
                    HStack{
                        VStack(alignment: .leading){
                            Text(player.firstName)
                                .bold()
                                .font(.title2)
                            //Handle Later: Multiple games
                            Text(manager.playerDetails[player.id]![0].gameID)
                                .font(.callout)
                        }
                        Spacer()
                    }
                }
                .onDelete { indexSet in
                    eventManager.removePlayerFromEventWith(indexSet: indexSet)
                }
                Button {
                    eventManager.isShowingAddPlayerToEvent     = true
                } label: {
                    Text("Add Player")
                        .foregroundColor(.blue)
                }
            }
            .sheet(isPresented: $eventManager.isShowingAddPlayerToEvent) {
                NavigationView {
                    AddExistingPlayer(viewModel: eventManager)
                }
            }
        }
        .environmentObject(eventManager)
        .onAppear{
            eventManager.event = event
        }
        .navigationTitle(eventManager.event.eventName)
        .task {
            eventManager.getMatchesForEvent()
            eventManager.getPlayersInEvents()
            eventManager.getAvailablePlayers(from: manager.players)
        }
        .toolbar {
            EditButton()
        }
        .alert(eventManager.alertItem.alertTitle, isPresented: $eventManager.isShowingAlert, actions: {}, message: {
            eventManager.alertItem.alertMessage
        })
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(event: TUEvent(record: MockData.event))
    }
}
