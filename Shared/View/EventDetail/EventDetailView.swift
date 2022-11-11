//
//  EventDetailView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/12/22.
//

import SwiftUI
import EventKit

//MARK: EventDetailView
//INFO: View that shows all details of the events: General Info, Matches, Participants
struct EventDetailView: View {

    @EnvironmentObject var playerManager: PlayerManager
    @EnvironmentObject var eventsManager: EventsManager
    @StateObject private var viewModel: EventDetailViewModel
    @Environment(\.dismiss) var dismiss

    init(event: TUEvent){ _viewModel = StateObject(wrappedValue: EventDetailViewModel(event: event)) }

    var body: some View {
        ScrollView {
            VStack {
                EventDetailsViewSection(viewModel: viewModel)
                    .padding(.horizontal, 12)
                EventLocationDetailViewSection(viewModel: viewModel)
                    .padding(.horizontal, 12)
                EventDescriptionViewSection(viewModel: viewModel)
                    .padding(.horizontal, 12)
                MatchesView(viewModel: viewModel)
                ParticipantsView(viewModel: viewModel)
                    .padding(.horizontal, 12)
            }
        }
        .refreshable {
            viewModel.refreshEventDetails()
        }
        .navigationTitle(viewModel.event.eventName)
        .sheet(isPresented: $viewModel.isShowingSheet){
            NavigationView {
                viewModel.presentSheet()
            }
            .presentationDetents([.medium, .large])
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
                    viewModel.sheetToPresent = .eventMoreDetail
                } label: {
                    Image(systemName: "info.square")
                        .foregroundColor(.blue)
                }

                if viewModel.isEventOwner(for: playerManager.playerProfileRecord) {
                    Menu {
                        if viewModel.event.isPublished == 0 && viewModel.isShowingPublishedButton && viewModel.event.isArchived == 0 {
                            Button {
                                viewModel.publishEvent(eventsManager: eventsManager)
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
                        Image(systemName: "ellipsis")
                            .foregroundColor(.blue)
                    }
                }
            }
        }
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

//MARK: EventLocationDetailViewSection
//INFO: Section that displays the location of event. On tap leads to Apple Maps or Discord
struct EventLocationDetailViewSection: View {
    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        HStack(spacing: 10){
            VStack(alignment: .leading, spacing: 5){
                if viewModel.event.eventLocation.contains("discord.gg"){
                    HStack(spacing: 4){
                        Image(systemName: "link")
                            .foregroundColor(.blue)
                        Text("Discord")
                            .bold()
                            .onTapGesture {
                                if let url = URL(string: "https://\(viewModel.event.eventLocation)") {
                                    UIApplication.shared.open(url)
                                }
                            }
                    }
                } else {
                    VStack(alignment: .leading,spacing: 10){
                        HStack(spacing: 4){
                            Image(systemName: DetailItem.location.getSystemImage())
                                .foregroundColor(.blue)
                            Text(DetailItem.location.getTextHeading())
                                .font(.callout)
                        }
                        VStack(alignment: .leading, spacing: 4){
                            if let eventLocationTitle = viewModel.event.eventLocationTitle {
                                Text(eventLocationTitle)
                                    .bold()
                            }
                            Text(viewModel.event.eventLocation)
                                .bold()
                                .lineLimit(1)
                                .minimumScaleFactor(0.75)
                                .onTapGesture {
                                    var url = URL(string: viewModel.event.eventLocation)
                                    if viewModel.event.eventLocation.starts(with: "discord.gg") {
                                        url = URL(string: "https://\(viewModel.event.eventLocation)")
                                        UIApplication.shared.open(url!)
                                    } else{
                                        url = URL(string: "maps://?address=\(viewModel.event.eventLocation.replacingOccurrences(of: " ", with: "%20"))&q=\(viewModel.event.eventLocationTitle?.replacingOccurrences(of: " ", with: "%20") ?? "")")
                                        UIApplication.shared.open(url!)
                                    }
                                }
                        }
                    }
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .padding(.horizontal, 10)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

//MARK: EventDetailsViewSection
//INFO: Displays DetailItemViews for date, start time, and end time.
struct EventDetailsViewSection: View {

    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        HStack(spacing: 5){
            DetailItemView(textContent: viewModel.event.getEventDetailDate, detailType: .date)
            Spacer()
            DetailItemView(textContent: viewModel.event.getTime, detailType: .time)
            Spacer()
            DetailItemView(textContent: viewModel.event.getEndTime, detailType: .endTime)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .padding(.horizontal, 10)
        .allowToPresentCalendar(with: viewModel)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

//MARK: DetailItemView
//INFO: Reused view to display Image and Title on top of the detail item text
struct DetailItemView: View {

    var textContent: String
    var detailType: DetailItem

    var body: some View {
        VStack(alignment: .center, spacing: 5){
            HStack(spacing: 4){
                Image(systemName: detailType.getSystemImage())
                    .foregroundColor(.blue)
                Text(detailType.getTextHeading())
                    .font(.callout)
            }
            Text(textContent)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }
}

//MARK: EventDescriptionViewSection
//INFO: Displays the description of the event
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
                //TIP: Make Collapsable
                Text(viewModel.event.eventDescription)
                    .lineLimit(15)
            }
            Spacer()
        }
        .padding(.vertical)
        .padding(.horizontal, 10)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

//MARK: MatchesView
//INFO: Displays a horizontal scroll view of EventMatchCells below the Matches title. Tapping on the cell leads to MatchDetailView
struct MatchesView: View {

    @EnvironmentObject var playerManager: PlayerManager
    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        VStack(alignment: .leading){
            HStack {
                Text("Matches")
                    .font(.title2)
                    .bold()
                Spacer()
                if viewModel.isEventOwner(for: playerManager.playerProfileRecord) && viewModel.event.isArchived == 0 {
                    Button {
                        viewModel.sheetToPresent = .addMatch
                        viewModel.resetMatchInput()
                    } label: {
                        Image(systemName: "rectangle.badge.plus")
                            .font(.system(size: 24, design: .default))
                    }
                }
            }
            .padding(.horizontal, 12)
            
            if viewModel.isLoading {
                LoadingView()
                    .padding(.top, 48)
            } else if viewModel.matches.isEmpty {
                HStack{
                    Spacer()
                    Text("No matches found")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .bold()
                    Spacer()
                }
                .padding()
            } else {
                ScrollView(.horizontal, showsIndicators: false){
                    HStack{
                        ForEach(viewModel.matches) { match in
                            NavigationLink {
                                MatchDetailView(viewModel: MatchDetailViewModel(match: match, event: viewModel.event))
                                    .environmentObject(viewModel)
                                    .onDisappear {
                                        viewModel.refreshEventDetails()
                                    }
                            } label: {
                                EventMatchCellView(matchName: match.matchName, matchTime: match.matchStartTime.convertDateToString())
                            }
                            .buttonStyle(PlainButtonStyle()) //Removes blue highlight from MatchCell
                        }
                    }
                    .offset(x: 12) //Shifts start position of cells to the right 16pt
                    .padding(.trailing, 24) //Makes last cell not cut off
                }
            }
        }
    }
}

//MARK: EventMatchCellView
//INFO: Event Match cell view
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
        .padding(.horizontal, 10)
        .padding(.vertical)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

//MARK: ParticipantsView
//INFO: Displays list of players in the event with the ability for a player to join or leave event. Owners can search and add players.
struct ParticipantsView: View {
    @EnvironmentObject var playerManager: PlayerManager
    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        VStack(alignment: .leading){
            HStack{
                Text("Participants")
                    .font(.title2)
                    .bold()
                Spacer()
                if viewModel.isEventOwner(for: playerManager.playerProfileRecord) && viewModel.event.isPublished == 1 {
                    NavigationLink {
                        AddPlayerToEventSheet(viewModel: viewModel)
                    } label: {
                        Image(systemName: "person.badge.plus")
                            .font(.system(size: 24, design: .default))
                    }
                } else if !viewModel.isEventOwner(for: playerManager.playerProfileRecord) && viewModel.event.isPublished == 1 {
                    if let playerProfile = playerManager.playerProfile {
                        if playerProfile.inEvents.contains(where: {$0.recordID == viewModel.event.id}) {
                            Button {
                                viewModel.leaveEvent(with: playerManager)
                            } label: {
                                Text("Leave")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.appPrimaryInverse)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.red)
                                    .cornerRadius(4)
                            }
                        } else {
                            Button {
                                viewModel.addPlayerToEvent(with: playerManager)
                            } label: {
                                Text("Join")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.appPrimaryInverse)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(.blue)
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }

            if viewModel.isLoading {
                LoadingView()
                    .padding(.top, 48)
            } else if viewModel.event.isPublished == 0 && viewModel.isEventOwner(for: playerManager.playerProfileRecord) && viewModel.event.isArchived == 0 {
                HStack{
                    Spacer()
                    Text("Publish event to manually add players")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .bold()
                        .multilineTextAlignment(.center)
                    Spacer()
                }
                .padding()
            } else if viewModel.playersInEvent.isEmpty {
                HStack{
                    Spacer()
                    Text("No participants found")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .bold()
                    Spacer()
                }
                .padding()
            } else {
                LazyVStack {
                    ForEach(viewModel.playersInEvent){ player in
                        EventParticipantCell(event: viewModel.event, player: player)
                            .onLongPressGesture {
                                //This stops scrolling
                                if viewModel.isEventOwner(for: playerManager.playerProfileRecord) && viewModel.event.isArchived == 0 {
                                    viewModel.removePlayerFromEventWith(for: player)
                                    //viewModel.refreshEventDetails(with: eventsManager.players)
                                }
                            }
                    }
                }
            }
        }
    }
}
