//
//  EventsListView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import SwiftUI

struct EventsListView: View {
    var body: some View {
        NavigationView{
            List {
                NavigationLink( destination: EventDetailView()){
                    EventListCell()
                }
                NavigationLink( destination: EventDetailView()){
                    EventListCell()
                }
                NavigationLink( destination: EventDetailView()){
                    EventListCell()
                }
                NavigationLink( destination: EventDetailView()){
                    EventListCell()
                }
            }
            .listStyle(.plain)
            .navigationTitle("Events")
            .toolbar {
                ToolbarItemGroup(placement: .primaryAction) {
                    Button {
                        print("Hello")
                    } label: {
                        Image(systemName: "plus.rectangle")
                            .tint(.blue)
                    }

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
