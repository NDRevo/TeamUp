//
//  EventsListView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import SwiftUI

struct EventsListView: View {

    @EnvironmentObject private var eventsManager: EventsManager
    @StateObject private var viewModel = EventsListViewModel()

    var body: some View {
        NavigationView {
            ZStack{
                Color.appBackground.edgesIgnoringSafeArea(.all)
                if eventsManager.events.isEmpty {
                    VStack(spacing: 12){
                        Image(systemName: "calendar")
                            .font(.system(size: 36))
                            .foregroundColor(.secondary)
                        Text("No events found")
                            .foregroundColor(.secondary)
                            .bold()
                    }
                    .offset(y: -128)
                } else{
                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(eventsManager.events){ event in
                                NavigationLink {
                                    EventDetailView(viewModel: EventDetailViewModel(event: event))
                                } label: {
                                    EventListCell(event: event)
                                }
                            }
                        }
                        .padding(12)
                    }
                }
            }
            .navigationTitle("Events")
            .task {
                eventsManager.getPublicEvents()
            }
            .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
                viewModel.alertItem.alertMessage
            })
        }
    }
}

struct EventsListView_Previews: PreviewProvider {
    static var previews: some View {
        EventsListView()
            .environmentObject(EventsManager())
    }
}
