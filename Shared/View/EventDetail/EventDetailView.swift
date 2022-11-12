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
                EventTimeDetailsView(viewModel: viewModel)
                    .padding(.horizontal, 12)
                EventLocationView(viewModel: viewModel)
                    .padding(.horizontal, 12)
                EventDescriptionView(viewModel: viewModel)
                    .padding(.horizontal, 12)
                EventMatchesView(viewModel: viewModel)
                EventParticipantsView(viewModel: viewModel)
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
                    viewModel.sheetToPresent = .eventMoreDetails
                } label: {
                    Image(systemName: "info.square")
                        .foregroundColor(.blue)
                }

                if viewModel.isEventOwner(for: playerManager.playerProfile?.record) {
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
