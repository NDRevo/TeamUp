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
        ScrollView {
            VStack {
                EventDetailsViewSection(viewModel: viewModel)
                EventDescriptionViewSection(viewModel: viewModel)

                VStack(alignment: .leading){
                    HStack {
                        Text("Matches")
                            .font(.title)
                        Spacer()
                        if viewModel.isEventOwner() {
                            Button {
                                viewModel.sheetToPresent = .addMatch
                                viewModel.resetMatchInput()
                            } label: {
                                Image(systemName: "rectangle.badge.plus")
                                    .font(.system(size: 24, design: .default))
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        LoadingView()
                            .padding(.top, 48)
                    } else if viewModel.matches.isEmpty {
                        HStack{
                            Spacer()
                            Text("No Matches Found")
                                .font(.title3)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false){
                            HStack{
                                ForEach(viewModel.matches) { match in
                                    NavigationLink(destination: MatchDetailView(viewModel: MatchDetailViewModel(match: match, playersInEvent: viewModel.playersInEvent, event: viewModel.event))) {
                                        EventMatchCellView(matchName: match.matchName, matchTime: match.matchStartTime.convertDateToString())
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                }
                            }
                            .offset(x: 16) //Shifts start position of cells to the right 16pt
                            .padding(.trailing, 24) //Makes last cell not cut off
                            
                        }
                    }
                }
                
                VStack(alignment: .leading){
                    HStack{
                        Text("Participants")
                            .font(.title)
                        Spacer()
                        if viewModel.isEventOwner() {
                            Button {
                                viewModel.sheetToPresent = .addPlayer
                            } label: {
                                Image(systemName: "person.badge.plus")
                                    .font(.system(size: 24, design: .default))
                            }
                        } else {
                            //Changes based on if already joined or not
                            Button {
                                
                            } label: {
                                Text("Join")
                                    .font(.title3)
                            }
                        }
                    }
                    
                    if viewModel.isLoading {
                        LoadingView()
                            .padding(.top, 48)
                    } else if viewModel.playersInEvent.isEmpty {
                        HStack{
                            Spacer()
                            Text("No Participants Yet!")
                                .font(.title3)
                                .foregroundColor(.gray)
                            Spacer()
                        }
                        .padding()
                    } else {
                        VStack {
                            ForEach(viewModel.playersInEvent){ player in
                                EventParticipantCellView(viewModel: viewModel, player: player)
                                    .onLongPressGesture {
                                        //Doesnt work
                                        if viewModel.isEventOwner() {
                                            viewModel.removePlayerFromEventWith(for: player)
                                            //viewModel.refreshEventDetails(with: eventsManager.players)
                                        }
                                    }
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(viewModel.event.eventName)
        .sheet(isPresented: $viewModel.isShowingSheet, onDismiss: {
            viewModel.refreshEventDetails()
        }){
            NavigationView{
                viewModel.presentSheet()
            }
        }
        .task {
            viewModel.setUpEventDetails()
        }
        .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
            viewModel.alertItem.alertMessage
        })
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.refreshEventDetails()
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                    }
                if viewModel.isEventOwner() {
                    Menu {
                        Text("Edit")
                        Text("Publish")
                        Button(role: .destructive) {
                            viewModel.deleteEvent(eventID: viewModel.event.id)
                            eventsManager.events.removeAll(where: {$0.id == viewModel.event.id})
                        } label: {
                            Text("Delete Event")
                        }

                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
        .background(Color.appBackground)
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
        HStack(spacing: 15){
            descriptionItem(systemImageName: "calendar", textHeading: "Date", textContent: viewModel.event.getEventDetailDate)
            Spacer()
            descriptionItem(systemImageName: "clock", textHeading: "Time", textContent: viewModel.event.getTime)
            Spacer()
            descriptionItem(systemImageName: "map", textHeading: "Location", textContent: viewModel.event.eventLocation)
        }
        .frame(maxWidth: .infinity)
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
                HStack(spacing: 4){
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

struct EventMatchCellView: View {

    var matchName: String
    var matchTime: String

    var body: some View {
        HStack(spacing: 32){
            VStack(alignment: .leading, spacing: 12){
                Text(matchName)
                    .bold()
                    .font(.title3)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.red)
                    .clipShape(Capsule())
                HStack {
                    Image(systemName: "clock.circle")
                    Text(matchTime)
                }
            }
            Image(systemName: "chevron.right")
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct EventParticipantCellView: View {
    
    @EnvironmentObject var manager: EventsManager
    @ObservedObject var viewModel: EventDetailViewModel
    

    var player: TUPlayer
    var playerProfile: TUPlayerGameProfile? {
        return manager.playerProfiles[player.id]?.first(where: {$0.gameName == viewModel.event.eventGame})
    }

    var body: some View {
        HStack{
            VStack(alignment: .leading){
                HStack{
                    if let playerProfile = playerProfile {
                        Text(playerProfile.gameID)
                            .bold()
                            .font(.title2)
                        Text("(\(player.firstName))")
                            .bold()
                            .font(.title2)
                    } else {
                        Text(player.firstName)
                            .font(.title2)
                    }
                }
                if let playerProfile = playerProfile {
                    Text(playerProfile.gameRank)
                        .fontWeight(.light)
                }
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.system(size: 20))
        }
        .padding(.horizontal)
        .frame(height: 65)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
