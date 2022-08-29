//
//  EventListCell.swift
//  TeamUp
//
//  Created by Noé Duran on 1/11/22.
//

import SwiftUI

//MARK: EventListCell
//INFO: Displays a rectangle (cell) with information about the event
struct EventListCell: View {
    @EnvironmentObject var eventsManager: EventsManager

    var event: TUEvent

    var body: some View {
        HStack {
            VStack(spacing: 30){
                HStack(alignment:.top){
                    EventDate(event: event)
                    VStack(alignment: .leading, spacing: 6){
                        EventGameName(event: event)
                        EventName(event: event)
                    }
                    Spacer()
                }
                .frame(height: 60)
                HStack{
                    EventInfoItem(infoItemText: "Start Time", eventItem: event.getTime)
                    Spacer()
                    EventInfoItem(infoItemText: "Location", eventItem: event.eventLocation)
                    Spacer()
                    EventInfoItem(infoItemText: "Players", eventItem: "\(eventsManager.playerCountPerEvent[event.id] ?? 0)")
                }
            }
            .padding(12)
            .background{
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.appCell)
            }
            .tint(.primary)
        }
    }
}

struct EventListCell_Previews: PreviewProvider {
    static var previews: some View {
        EventListCell(event: TUEvent(record: MockData.event))
            .environmentObject(EventsManager())
    }
}

//MARK: EventGameName
//INFO: Displays name of the game for the event
struct EventGameName: View {
    var event: TUEvent

    var body: some View {
        Text(event.eventGameName + event.eventGameVariantName)
            .minimumScaleFactor(0.90)
            .lineLimit(1)
            .truncationMode(.tail)
            .fontWeight(.heavy)
            .font(.body)
            .foregroundColor(.appCell)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(Color.getGameColor(gameName: event.eventGameName))
                    .frame(height: 25)
            }
            .multilineTextAlignment(.leading)
    }
}

//MARK: EventName
//INFO: Displays name of the event
struct EventName: View {
    var event: TUEvent
    var body: some View {
        Text(event.eventName)
            .fontWeight(.bold)
            .font(.title)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
    }
}

//MARK: EventDate
//INFO: Displays date of event located at the top right of the event cell
struct EventDate: View {
    var event: TUEvent

    var body: some View {
        VStack(alignment: .center){
            Text("\(event.getMonth)")
                .fontWeight(.medium)
                .font(.body)
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            Text("\(event.getDateDetails.day!)")
                .bold()
                .font(.title)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.appBackground)
        }
    }
}

//MARK: EventInfoItem
//INFO: View that displays more info about the event located at the bottom half of the cell
struct EventInfoItem: View {
    var infoItemText: String
    var eventItem: String
    
    var body: some View {
        VStack(alignment: .center,spacing: 5){
            Text(infoItemText)
                .fontWeight(.medium)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text("\(eventItem)")
                .bold()
                .font(.body)
                .lineLimit(1)
        }
    }
}
