//
//  CoreDataDebugView.swift
//  TeamUp
//
//  Created by Noé Duran on 9/3/22.
//

import SwiftUI

struct CoreDataDebugView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) var events: FetchedResults<Event>
    
    @State var isPresentingSheet = false
    var body: some View {
        NavigationView {

            ScrollView{
                ForEach(events) { event in
                    NavigationLink {
                        CDDetailView(event: event)
                    } label: {
                        Text(event.eventName ?? "Name")
                            .bold()
                    }
                }
            }
            .navigationTitle("Core Data")
            .toolbar {
                ToolbarItem {
                    Image(systemName: "gear")
                        .onTapGesture {
                            createEvent()
                        }
                }
            }
            .sheet(isPresented: $isPresentingSheet) {
                Image(systemName: "gear")
            }
        }

    }
    
    func createEvent(){
        let event = Event(context: viewContext)
        event.eventName = "New Event"
        event.eventDate = Date()
        event.eventOwner = "Noe Duran"
        event.eventDescription = "WELCOME"
        event.eventEndDate = Date()
        event.eventSchool = "Rutgers"
        event.eventGameName = "Overwatch"
        event.eventLocation = "Location"
        do {
            try viewContext.save()
        } catch {
            print("NEWERROR: \(error)")
        }
    }
}


struct CDDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) var matches: FetchedResults<EventMatch>
    var event: Event
    
    public var matchesArray: [EventMatch] {
        let set = event.hasMatch! as? Set<EventMatch> ?? []
        return set.sorted {
            $0.matchStartTime! < $1.matchStartTime!
        }
    }
    
    var body: some View {
        VStack {
            Text(event.eventName!)
            Text(event.eventDate!.convertDateToString())
            Text(event.eventOwner!)
            Text(event.eventDescription!)
            Text(event.eventEndDate!.convertDateToString())
            Text(event.eventSchool!)
            Text(event.eventGameName!)
            Text(event.eventLocation!)
            Text(event.eventGameVariantName ?? "N/A")
            
            ForEach(matchesArray) { match in
                Text(match.matchName!)
            }
        }
        .navigationTitle(event.eventName ?? "Event")
        .toolbar {
            Image(systemName: "circle.fill")
                .onTapGesture {
                    let match = EventMatch(context: viewContext)
                    match.matchName = "Match Name"
                    match.matchStartTime = Date()
                    match.associatedToEvent = event
                    do {
                        try viewContext.save()
                    } catch {
                        print(error)
                    }
                }
        }
    }
}

struct CoreDataDebugView_Previews: PreviewProvider {
    static var previews: some View {
        CoreDataDebugView()
    }
}
