//
//  EventDetailView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/12/22.
//

import SwiftUI

struct EventDetailView: View {

    @StateObject var eventDetailManager = EventDetailManager()

    @EnvironmentObject var eventsManager: EventsManager
    @ObservedObject var viewModel: EventDetailViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        ScrollView {
            VStack {
                EventDetailsViewSection(viewModel: viewModel)
                EventDescriptionViewSection(viewModel: viewModel)
                MatchesView(viewModel: viewModel)
                ParticipantsView(viewModel: viewModel)
            }
        }
        .navigationTitle(viewModel.event.eventName)
        .sheet(isPresented: $viewModel.isShowingSheet, onDismiss: {
            viewModel.refreshEventDetails(eventDetailManager: eventDetailManager)
        }){
            NavigationView {
                viewModel.presentSheet()
            }
            .presentationDetents([.medium, .large])
        }
        .task {
            viewModel.setUpEventDetails(eventDetailManager: eventDetailManager)
        }
        .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
            viewModel.alertItem.alertMessage
        })
        .environmentObject(eventDetailManager)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.refreshEventDetails(eventDetailManager: eventDetailManager)
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.blue)
                    }
                if viewModel.isEventOwner() {
                    Menu {
                        if viewModel.event.isPublished == 0 {
                            Button {
                                viewModel.publishEvent(eventsManager: eventsManager)
                                eventsManager.getMyPublishedEvents()
                                eventsManager.getMyUnpublishedEvents()
                            } label: {
                                Text("Publish")
                            }
                        }

                        Button(role: .destructive) {
                            viewModel.isShowingConfirmationDialogue = true
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
        //BUG: Fails as of Xcode 14 beta 1: NavigationAuthority
        .confirmationDialog("Delete Event?", isPresented: $viewModel.isShowingConfirmationDialogue, actions: {
            Button(role: .destructive) {
                eventsManager.deleteEvent(for: viewModel.event)
            } label: {
                Text("Delete")
            }
        }, message: {
            Text("Do you want to delete the event? You won't be able to recover it.")
        })
        .background(Color.appBackground)
    }
}

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)))
    }
}

//MARK: EventDetailsViewSection

struct EventDetailsViewSection: View {
    
    @ObservedObject var viewModel: EventDetailViewModel
    
    var body: some View {
        HStack(spacing: 10){
            DetailItemView(systemImageName: "calendar", textHeading: "Date", textContent: viewModel.event.getEventDetailDate)
            Spacer()
            DetailItemView(systemImageName: "clock", textHeading: "Time", textContent: viewModel.event.getTime)
            Spacer()
            DetailItemView(systemImageName: "map", textHeading: "Location", textContent: viewModel.event.eventLocation)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .padding(.horizontal)
    }
}

//MARK: DetailItemView

struct DetailItemView: View {

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

//MARK: MatchesView

struct MatchesView: View {

    @ObservedObject var viewModel: EventDetailViewModel
    @EnvironmentObject var eventDetailManager: EventDetailManager

    var body: some View {
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
            } else if eventDetailManager.matches.isEmpty {
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
                        ForEach(eventDetailManager.matches) { match in
                            NavigationLink {
                                MatchDetailView(viewModel: MatchDetailViewModel(match: match, event: viewModel.event)).environmentObject(eventDetailManager)
                                    .onDisappear {
                                        viewModel.refreshEventDetails(eventDetailManager: eventDetailManager)
                                    }
                            } label: {
                                EventMatchCellView(matchName: match.matchName, matchTime: match.matchStartTime.convertDateToString())
                            }
                            .buttonStyle(PlainButtonStyle()) //Removes blue highlight from MatchCell
                        }
                    }
                    .offset(x: 16) //Shifts start position of cells to the right 16pt
                    .padding(.trailing, 24) //Makes last cell not cut off
                }
            }
        }
    }
}

//MARK: EventMatchCellView

struct EventMatchCellView: View {

    var matchName: String
    var matchTime: String

    var body: some View {
        HStack(spacing: 32){
            VStack(alignment: .leading, spacing: 12){
                Text(matchName)
                    .foregroundColor(Color.appCell)
                    .bold()
                    .font(.title3)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    //Adjust based on amount of events
                    .background(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                HStack {
                    Image(systemName: "calendar.badge.clock")
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

//MARK: ParticipantsView

struct ParticipantsView: View {

    @ObservedObject var viewModel: EventDetailViewModel
    @EnvironmentObject var eventDetailManager: EventDetailManager

    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Text("Participants")
                    .font(.title)
                Spacer()
                if viewModel.isEventOwner() {
                    NavigationLink {
                        AddExistingPlayerSheet(viewModel: viewModel)
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
            } else if eventDetailManager.playersInEvent.isEmpty {
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
                    ForEach(eventDetailManager.playersInEvent){ player in
                        EventParticipantCell(eventGame: viewModel.event.eventGame, player: player)
                            .onLongPressGesture {
                                //This stops scrolling
                                if viewModel.isEventOwner() {
                                    viewModel.removePlayerFromEventWith(for: player, eventDetailManager: eventDetailManager)
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
