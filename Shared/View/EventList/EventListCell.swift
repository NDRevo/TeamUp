//
//  EventListCell.swift
//  TeamUp
//
//  Created by Noé Duran on 1/11/22.
//

import SwiftUI

struct EventListCell: View {

    @EnvironmentObject var eventsManager: EventsManager

    var event: TUEvent

    var body: some View {
        HStack {
            VStack(spacing: 30){
                HStack(alignment:.top){
                    
                    VStack(alignment: .leading, spacing: 6){
                        Text(event.eventGameName + event.eventGameVariantName)
                            .fontWeight(.heavy)
                            .font(.body)
                            .foregroundColor(.appCell)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(Color.getGameColor(gameName: event.eventGameName))
                            }
                            .multilineTextAlignment(.leading)
                        Text(event.eventName)
                            .fontWeight(.bold)
                            .font(.title)
                            .lineLimit(1)
                            .minimumScaleFactor(0.75)
                    }
                    
                    Spacer()
                    
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
                HStack{
                    VStack(alignment: .center,spacing: 5){
                        Text("Time")
                            .fontWeight(.medium)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(event.getTime)")
                            .bold()
                            .font(.body)
                    }
                    Spacer()
                    VStack(alignment: .center,spacing: 5){
                        Text("Location")
                            .fontWeight(.medium)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(event.eventLocation)
                            .bold()
                            .font(.body)
                            .lineLimit(1)
                    }
                    Spacer()
                    VStack(alignment: .center,spacing: 5){
                        Text("Players")
                            .fontWeight(.medium)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(eventsManager.playerCountPerEvent[event.id] ?? 0)")
                            .bold()
                            .font(.body)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
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
