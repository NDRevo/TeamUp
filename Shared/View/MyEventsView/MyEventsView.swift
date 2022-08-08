//
//  MyEventsView.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 6/8/22.
//

import SwiftUI

struct MyEventsView: View {

    @StateObject private var viewModel = MyEventsViewModel()
    @EnvironmentObject private var eventsManager: EventsManager

    var body: some View {
        NavigationView {
            ZStack{
                Color.appBackground.edgesIgnoringSafeArea(.all)
                if !eventsManager.myUnpublishedEvents.isEmpty || !eventsManager.myPublishedEvents.isEmpty {
                    ScrollView {
                        VStack(alignment: .leading){
                            if !eventsManager.myUnpublishedEvents.isEmpty {
                                Text("Unpublished Events")
                                    .bold()
                                    .font(.title2)
                                VStack(spacing: 12){
                                    ForEach(eventsManager.myUnpublishedEvents) { event in
                                        NavigationLink {
                                            EventDetailView(viewModel: EventDetailViewModel(event: event))
                                        } label: {
                                            EventListCell(event: event)
                                        }
                                    }
                                }
                            }

                            if !eventsManager.myPublishedEvents.isEmpty {
                                Text("Published Events")
                                    .bold()
                                    .font(.title2)
                                VStack(spacing: 12){
                                    ForEach(eventsManager.myPublishedEvents) { event in
                                        NavigationLink {
                                            EventDetailView(viewModel: EventDetailViewModel(event: event))
                                        } label: {
                                            EventListCell(event: event)
                                        }
                                    }
                                }
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 12)
                    }
                } else {
                    VStack(spacing: 12){
                        Image(systemName: "calendar.badge.plus")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary)
                        Text("You have no events")
                            .foregroundColor(.secondary)
                            .bold()
                    }
                    .offset(y: -90)
                }
            }
            .navigationTitle(Text("My Events"))
            .task {
                eventsManager.getMyPublishedEvents()
                eventsManager.getMyUnpublishedEvents()
            }
            .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
                viewModel.alertItem.alertMessage
            })
            .toolbar {
                EventsListToolbarContent(viewModel: viewModel)
            }
            .sheet(isPresented: $viewModel.isPresentingAddEvent) {
                NavigationView {
                    AddEventSheet(viewModel: viewModel)
                }
            }
        }
    }
}

struct MyEventsView_Previews: PreviewProvider {
    static var previews: some View {
        MyEventsView()
    }
}

struct EventsListToolbarContent: ToolbarContent {
    @ObservedObject var viewModel: MyEventsViewModel

    var body: some ToolbarContent {
        ToolbarItemGroup(placement: .primaryAction) {
            Button {
                viewModel.isPresentingAddEvent = true
                viewModel.resetInput()
            } label: {
                Image(systemName: "plus.rectangle")
                    .tint(.blue)
            }
            .accessibilityLabel("Create Event")
        }
    }
}
