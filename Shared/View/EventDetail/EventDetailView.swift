//
//  EventDetailView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/12/22.
//

import SwiftUI

struct EventDetailView: View {

    @EnvironmentObject var eventsManager: EventsManager
    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        VStack {
            EventDetailsViewSection(viewModel: viewModel)
            EventDescriptionViewSection(viewModel: viewModel)

            List {
               

                Section(header: Text("Matches")) {
                    ForEach(viewModel.matches) { match in
                        NavigationLink(destination: MatchDetailView(viewModel: MatchDetailViewModel(match: match, playersInEvent: viewModel.playersInEvent, event: viewModel.event))) {
                            VStack(alignment: .leading){
                                Text(match.matchName)
                                Text(match.matchStartTime.convertDateToString())
                                    .font(.caption)
                            }
                        }
                        .swipeActions(edge: .trailing) {
                            if viewModel.isEventOwner() {
                                Button(role: .destructive){
                                    viewModel.deleteMatch(matchID: match.id)
                                    viewModel.matches.removeAll(where: {$0.id == match.id})
                                } label: {
                                    Label("Remove Player", systemImage: "minus.circle.fill")
                                }
                            }
                        }
                    }

                    if viewModel.isEventOwner() {
                        Button {
                            viewModel.sheetToPresent = .addMatch
                            viewModel.resetMatchInput()
                        } label: {
                            Text("Add Match")
                                .foregroundColor(.blue)
                        }
                        
                    }
                }

                Section(header: Text("Players")) {
                    ForEach(viewModel.playersInEvent){ player in
                        HStack{
                            VStack(alignment: .leading){
                                Text(player.firstName)
                                    .bold()
                                    .font(.title2)
                                ForEach(eventsManager.playerProfiles[player.id].flatMap({$0}) ?? []){ playerProfile in
                                    if playerProfile.gameName == viewModel.event.eventGame {
                                        Text(playerProfile.gameID)
                                            .font(.callout)
                                    }
                                }
                            }
                            Spacer()
                        }
                        .swipeActions(edge: .trailing) {
                            if viewModel.isEventOwner() {
                                Button(role: .destructive){
                                    viewModel.removePlayerFromEventWith(for: player)
                                    //viewModel.refreshEventDetails(with: eventsManager.players)
                                } label: {
                                    Label("Delete Player", systemImage: "minus.circle.fill")
                                }
                            }
                        }
                    }
                    if viewModel.isEventOwner() {
                        Button {
                            viewModel.sheetToPresent = .addPlayer
                        } label: {
                            Text("Add Player")
                                .foregroundColor(.blue)
                        }
                    }
                }
                if viewModel.isEventOwner() {
                    Button(role: .destructive) {
                        viewModel.deleteEvent(eventID: viewModel.event.id)
                        eventsManager.events.removeAll(where: {$0.id == viewModel.event.id})
                    } label: {
                        Text("Delete Event")
                    }
                }
            }
            .navigationTitle(viewModel.event.eventName)
            .refreshable {
                viewModel.refreshEventDetails(with: eventsManager.players)
            }
            .sheet(isPresented: $viewModel.isShowingSheet, onDismiss: {
                viewModel.refreshEventDetails(with: eventsManager.players)
            }){
                NavigationView{
                    viewModel.presentSheet()
                }
            }
            .task {
                viewModel.setUpEventDetails(with: eventsManager.players)
            }
            .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
                viewModel.alertItem.alertMessage
            })
        }
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)))
    }
}

struct EventDetailsViewSection: View {

    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        HStack(spacing: 20){
            descriptionItem(systemImageName: "calendar", textHeading: "Date", textContent: viewModel.event.getEventDetailDate)
            Divider()
                .foregroundColor(.black)
                .frame(width: 2, height: 50)
            descriptionItem(systemImageName: "clock", textHeading: "Time", textContent: viewModel.event.getTime)
            Divider()
                .foregroundColor(.black)
                .frame(width: 2, height: 50)
            descriptionItem(systemImageName: "map", textHeading: "Location", textContent: viewModel.event.eventLocation)
        }
        .padding()
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
}

struct descriptionItem: View {
    
    var systemImageName: String
    var textHeading: String
    var textContent: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 5){
            HStack(spacing: 4){
                Image(systemName: systemImageName)
                    .foregroundColor(.blue)
                Text(textHeading)
                    .font(.callout)
            }
            Text(textContent)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }
}

struct EventDescriptionViewSection: View {

    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        
        HStack{
            VStack(alignment: .leading, spacing: 10){
                HStack{
                    Image(systemName: "doc.plaintext")
                        .foregroundColor(.blue)
                    Text("Description")
                }
                Text(viewModel.event.eventDescription)
                    
            }
            Spacer()
        }
        .padding()
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
}

