//
//  EventDetailView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/12/22.
//

import SwiftUI
import EventKit

struct EventDetailView: View {

    @EnvironmentObject var eventsManager: EventsManager
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel: EventDetailViewModel

    init(event: TUEvent){
        _viewModel = StateObject(wrappedValue: EventDetailViewModel(event: event))
    }

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
        .sheet(isPresented: $viewModel.isShowingSheet, onDismiss: {
            viewModel.refreshEventDetails()
        }){
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
        //MARK: BUG: Fails as of Xcode 14 beta 1: NavigationAuthority
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

//MARK: EventDetailView_Preview

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(event: TUEvent(record: MockData.event))
    }
}

enum DetailItem {
    case date,time,endTime,location

    func getSystemImage() -> String {
        switch self {
        case .date: return "calendar"
        case .time: return "clock"
        case .location: return "map"
        case .endTime: return "clock.badge.exclamationmark"
        }
    }

    func getTextHeading() -> String {
        switch self {
        case .date: return "Date"
        case .time: return "Start Time"
        case .location: return "Location"
        case .endTime: return "End Time"
        }
    }
}

struct EventLocationDetailViewSection: View {

    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        HStack(spacing: 10){
            LocationDetailItemView(textContent: viewModel.event.eventLocation, detailType: .location)
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

//MARK: LocationDetailItemView

struct LocationDetailItemView: View {

    var textContent: String
    var detailType: DetailItem

    var body: some View {
        VStack(alignment: .leading, spacing: 5){
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
        .padding(.vertical)
        .padding(.horizontal, 10)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

//MARK: MatchesView

struct MatchesView: View {

    @ObservedObject var viewModel: EventDetailViewModel

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

struct ParticipantsView: View {
    @EnvironmentObject var eventsManager: EventsManager
    @ObservedObject var viewModel: EventDetailViewModel

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
                    if let playerProfile = eventsManager.userProfile {
                        if playerProfile.inEvents.contains(where: {$0.recordID == viewModel.event.id}) {
                            Button {
                                viewModel.leaveEvent(for: playerProfile, manager: eventsManager)
                            } label: {
                                Text("Leave")
                                    .font(.title3)
                            }
                        } else {
                            Button {
                                viewModel.addPlayerToEvent(for: playerProfile, manager: eventsManager)
                            } label: {
                                Text("Join")
                                    .font(.title3)
                            }
                        }
                    }
                }
            }

            if viewModel.isLoading {
                LoadingView()
                    .padding(.top, 48)
            } else if viewModel.playersInEvent.isEmpty {
                HStack{
                    Spacer()
                    Text("No participants, yet")
                        .font(.title3)
                        .foregroundColor(.secondary)
                        .bold()
                    Spacer()
                }
                .padding()
            } else {
                LazyVStack {
                    ForEach(viewModel.playersInEvent){ player in
                        EventParticipantCell(eventGame: viewModel.event.eventGameName, player: player)
                            .onLongPressGesture {
                                //This stops scrolling
                                if viewModel.isEventOwner() {
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
