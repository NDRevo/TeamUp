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
            VStack(spacing: appCellSpacing) {
                EventTitleView(viewModel: viewModel)
                    .padding(.horizontal, 10) // More of an inset
                VStack(spacing: appCellSpacing) {
                    EventTimeDetailsView(viewModel: viewModel)
                    EventLocationView(viewModel: viewModel)
                    EventDescriptionView(viewModel: viewModel)
                    if viewModel.isEditingEventDetails {
                        EditGameView(viewModel: viewModel)
                    }
                }
                .padding(.horizontal, appHorizontalViewPadding)
                if !viewModel.isEditingEventDetails {
                    EventMatchesView(viewModel: viewModel)
                    EventParticipantsView(viewModel: viewModel)
                        .padding(.horizontal, appHorizontalViewPadding)
                }
            }
            Spacer()
        }
        //Might not need
        .navigationBarTitleDisplayMode(.inline)
        .refreshable {
            viewModel.refreshEventDetails()
        }
        .sheet(isPresented: $viewModel.isShowingSheet){
            NavigationView {
                viewModel.presentSheet()
            }
            .presentationDetents([.medium, .large])
        }
        .task {
            viewModel.setUpEventDetails()
        }
        .alert($viewModel.isShowingEventDetailViewAlert, alertInfo: viewModel.alertItem)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                EventDetailToolbarButtons(viewModel: viewModel)
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

struct EventDetailView_Previews: PreviewProvider {
    static var previews: some View {
        EventDetailView(event: TUEvent(record: MockData.event))
            .environmentObject(PlayerManager(iCloudRecord: MockData.player, playerProfile: TUPlayer(record: MockData.player)))
            .environmentObject(EventsManager())
    }
}

struct EventTitleView: View {
    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        HStack {
            TextField(text: $viewModel.editedEventName) {
                Text(viewModel.event.eventName)
                    .foregroundColor(viewModel.isEditingEventDetails ? .gray : .primary)
            }
            .font(.system(.largeTitle, design: .rounded, weight: .bold))
            .disabled(!viewModel.isEditingEventDetails)
            Spacer()
        }
    }
}

struct EventDetailToolbarButtons: View {
    @EnvironmentObject var eventsManager: EventsManager
    @EnvironmentObject var playerManager: PlayerManager
    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        
        //Information Button
        if !viewModel.isEditingEventDetails {
            Button {
                viewModel.sheetToPresent = .eventMoreDetails
            } label: {
                Image(systemName: "info.circle")
                    .foregroundColor(.blue)
            }
        }

        //If the event owner
        if viewModel.isEventOwner(for: playerManager.playerProfile?.record) {
            //If not published and not archived
            if viewModel.event.isPublished == 0 && viewModel.event.isArchived == 0 {
                //Start editing or cancel editing
                Button {
                    withAnimation {
                        viewModel.isEditingEventDetails.toggle()
                    }
                } label: {
                    Image(systemName: viewModel.isEditingEventDetails ? "rectangle.badge.xmark" : "pencil.circle")
                        .foregroundStyle(viewModel.isEditingEventDetails ? .red : .blue, .blue)
                }
            }

            //If editing
            if viewModel.isEditingEventDetails {
                //Save event details button
                Button {
                    Task{ await viewModel.saveEditedEventDetails() }
                } label: {
                    Image(systemName: "rectangle.badge.checkmark")
                        .foregroundStyle(.green, .primary)
                }
            } else {
                Menu {
                    //If not published and not archived
                    if viewModel.event.isPublished == 0 && viewModel.isShowingPublishedButton && viewModel.event.isArchived == 0 {
                        Button {
                            viewModel.publishEvent(eventsManager: eventsManager)
                        } label: {
                            Text("Publish")
                        }
                    }

                    //Delete event button
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
}
