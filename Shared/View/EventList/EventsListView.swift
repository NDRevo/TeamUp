//
//  EventsListView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import SwiftUI

struct EventsListView: View {
    
    @EnvironmentObject var eventsManager: EventsManager
    @State var isPresentingAddEvent: Bool = false
    
    var body: some View {
        NavigationView{
            List {
                ForEach(eventsManager.events){ event in
                    NavigationLink( destination: EventDetailView(event: event)){
                        EventListCell(event: event)
                    }
                }
            }
            .listStyle(.plain)
            .navigationTitle("Events")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        isPresentingAddEvent = true
                    } label: {
                        Image(systemName: "plus.rectangle")
                            .tint(.blue)
                    }
                }
            }
            .sheet(isPresented: $isPresentingAddEvent){
                NavigationView {
                    AddEventSheet(eventGame: Games.VALORANT)
                        .toolbar { Button("Dismiss") { isPresentingAddEvent = false } }
                        .navigationTitle("Create Event")
                }
            }
        }
    }
}

struct EventsListView_Previews: PreviewProvider {
    static var previews: some View {
        EventsListView()
    }
}
