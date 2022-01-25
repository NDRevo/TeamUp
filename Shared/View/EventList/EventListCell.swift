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
           Rectangle()
                .frame(width: 30, height: 120)
                .foregroundColor(Color.getGameColor(gameName: event.eventGame))
                .cornerRadius(8, corners: [.topLeft, .bottomLeft])
                
            VStack(spacing: 10){
                HStack{
                    VStack(alignment: .leading){
                        Text(event.eventGame)
                            .bold()
                            .font(.body)
                            .foregroundColor(.secondary)
                        Text(event.eventName)
                            .bold()
                            .font(.title2)
                    }
                    Spacer()
                    VStack(alignment: .trailing){
                        Text("\(event.getMonth)")
                            .bold()
                            .font(.body)
                            .foregroundColor(.secondary)
                        Text("\(event.getDateDetails.day!)")
                            .bold()
                            .font(.title2)
                    }
                }
                HStack{
                    VStack(alignment: .center,spacing: 5){
                        Text("Time")
                            .bold()
                            .font(.body)
                            .foregroundColor(.secondary)
                        Text("\(event.getTime)")
                            .bold()
                            .font(.subheadline)
                    }
                    Spacer()
                    VStack(alignment: .center,spacing: 5){
                        Text("Location")
                            .bold()
                            .font(.body)
                            .foregroundColor(.secondary)
                        Text(event.eventLocation)
                            .bold()
                            .font(.subheadline)
                            .lineLimit(1)
                    }
                    Spacer()
                    VStack(alignment: .center,spacing: 5){
                        Text("Players")
                            .bold()
                            .font(.body)
                            .foregroundColor(.secondary)
                        Text("\(eventsManager.playerCountPerEvent[event.id] ?? 0)")
                            .bold()
                            .font(.subheadline)
                    }
                }
            }
            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 15))
        }
    }
}

struct EventListCell_Previews: PreviewProvider {
    static var previews: some View {
        EventListCell(event: TUEvent(record: MockData.event))
            .environment(\.sizeCategory, .large)
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
