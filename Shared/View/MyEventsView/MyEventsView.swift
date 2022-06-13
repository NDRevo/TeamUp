//
//  MyEventsView.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 6/8/22.
//

import SwiftUI

struct MyEventsView: View {
    
//    @StateObject private var viewModel = MyEventsViewModel()
    @EnvironmentObject private var eventsManager: EventsManager
    
    @State private var myPublishedEvents: [TUEvent] = []
    @State private var myUnpublishedEvents: [TUEvent] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading){
                    if !myUnpublishedEvents.isEmpty {
                        Text("Unpublished Events")
                            .bold()
                            .font(.title2)
                            .padding(.horizontal)
                        ForEach(myUnpublishedEvents) { event in
                            NavigationLink {
                                EventDetailView(viewModel: EventDetailViewModel(event: event))
                            } label: {
                                EventListCell(event: event)
                            }
                        }
                    }
                    
                    if !myPublishedEvents.isEmpty {
                        Text("Published Events")
                            .bold()
                            .font(.title2)
                            .padding(.horizontal)
                        ForEach(myPublishedEvents) { event in
                            NavigationLink(value: event){
                                EventListCell(event: event)
                            }
                        }
                    }
                    Spacer()
                }
            }
            .navigationTitle(Text("My Events"))
            .task {
                getMyPublishedEvents()
                getMyUnpublishedEvents()
            }
            .refreshable {
                getMyPublishedEvents()
                getMyUnpublishedEvents()
            }
        }

    }
    
    func getMyPublishedEvents(){
        Task {
            do{
                myPublishedEvents = try await CloudKitManager.shared.getEvents(thatArePublished: true, withSpecificOwner: true)
            } catch {
//                alertItem = AlertContext.unableToRetrieveEvents
//                isShowingAlert = true
            }
        }
    }
    
    func getMyUnpublishedEvents(){
        Task {
            do{
               myUnpublishedEvents = try await CloudKitManager.shared.getEvents(thatArePublished: false, withSpecificOwner: true)
            } catch {
//                alertItem = AlertContext.unableToRetrieveEvents
//                isShowingAlert = true
            }
        }
    }
}

struct MyEventsView_Previews: PreviewProvider {
    static var previews: some View {
        MyEventsView()
    }
}
