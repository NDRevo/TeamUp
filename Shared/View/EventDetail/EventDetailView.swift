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
                    ScrollView(.horizontal, showsIndicators: false){
                        HStack{
                            ForEach(viewModel.matches) { match in
                                NavigationLink(destination: MatchDetailView(viewModel: MatchDetailViewModel(match: match, playersInEvent: viewModel.playersInEvent, event: viewModel.event))) {
                                    EventMatchCellView(matchName: match.matchName, matchTime: match.matchStartTime.convertDateToString())
                                }
                                .buttonStyle(PlainButtonStyle())
                                //                            .swipeActions(edge: .trailing) {
                                //                                if viewModel.isEventOwner() {
                                //                                    Button(role: .destructive){
                                //                                        viewModel.deleteMatch(matchID: match.id)
                                //                                        viewModel.matches.removeAll(where: {$0.id == match.id})
                                //                                    } label: {
                                //                                        Label("Remove Player", systemImage: "minus.circle.fill")
                                //                                    }
                                //                                }
                                //                            }
                            }
                        }
                        .offset(x: 16) //Shifts start position of cells to the right 16pt
                        .padding(.trailing, 24) //Makes last cell not cut off
                        
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
                        }
                    }
                    VStack {
                        ForEach(viewModel.playersInEvent){ player in
                            EventParticipantCellView(participantName: player.firstName, participantGameID: player.lastName)
                            //                            .swipeActions(edge: .trailing) {
                            //                                    Button(role: .destructive){
                            //                                        viewModel.removePlayerFromEventWith(for: player)
                            //                                        //viewModel.refreshEventDetails(with: eventsManager.players)
                            //                                    } label: {
                            //                                        Label("Delete Player", systemImage: "minus.circle.fill")
                            //                                    }
                            //                            }
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .navigationTitle(viewModel.event.eventName)
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
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.refreshEventDetails(with: eventsManager.players)
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
            Divider()
            descriptionItem(systemImageName: "clock", textHeading: "Time", textContent: viewModel.event.getTime)
            Divider()
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
    
    var participantName: String
    var participantGameID: String
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(participantName)
                    .bold()
                    .font(.title2)
                Text(participantGameID)
            }
            Spacer()
            Image(systemName: "chevron.right")
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
