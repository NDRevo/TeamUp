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

    var eventLocation: String {
        if let eventLocationTitle = event.eventLocationTitle {
            return eventLocationTitle
        } else {
           return event.eventLocation
        }
    }

    var body: some View {
        HStack {
            VStack(spacing: 30){
                HStack(alignment:.center){
                    EventDate(event: event)
                    VStack(alignment: .leading, spacing: 4){
                        EventGameName(event: event)
                        EventName(event: event)
                    }
                    Spacer()
                }
                .frame(height: 60)
                HStack{
                    EventInfoItem(infoItemText: "Start Time", eventItem: event.getTime)
                    Spacer()
                    EventInfoItem(infoItemText: "Location", eventItem: eventLocation)
                        .frame(width: 150)
                    Spacer()
                    EventInfoItem(infoItemText: "Players", eventItem: "\(eventsManager.playerCountPerEvent[event.id] ?? 0)")
                }
            }
            .padding(appCellPadding)
            .background{
                RoundedRectangle(cornerRadius: appCornerRadius)
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
        Text(event.processedGameName)
            .minimumScaleFactor(appMinimumScaleFactor)
            .lineLimit(1)
            .truncationMode(.tail)
            .font(.system(.body, design: .rounded, weight: .heavy))
            .foregroundColor(.appCell)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background {
                RoundedRectangle(cornerRadius: appCornerRadius)
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
            .font(.system(.title, design: .rounded, weight: .bold))
            .lineLimit(1)
            .minimumScaleFactor(appMinimumScaleFactor)
    }
}

//MARK: EventDate
//INFO: Displays date of event located at the top right of the event cell
struct EventDate: View {
    var event: TUEvent

    var body: some View {
        VStack(alignment: .center){
            Text("\(event.getMonth)")
                .font(.system(.body, design: .monospaced, weight: .medium))
                .foregroundColor(.secondary)
                .textCase(.uppercase)
            Text("\(event.getDateDetails.day!)")
                .font(.system(.title, design: .monospaced, weight: .bold))
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background {
            RoundedRectangle(cornerRadius: appCornerRadius)
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
        VStack(alignment: .center, spacing: (appHeaderToContentSpacing/2)){
            Text(infoItemText)
                .font(.system(.callout, design: .monospaced, weight: .medium))
                .foregroundColor(.secondary)
            Text("\(eventItem)")
                .font(.system(.body, design: .rounded, weight: .regular))
                .lineLimit(1)
                .minimumScaleFactor(appMinimumScaleFactor)
        }
    }
}
