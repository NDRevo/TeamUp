//
//  EventListCell.swift
//  TeamUp
//
//  Created by Noé Duran on 1/11/22.
//

import SwiftUI

struct EventListCell: View {
    var body: some View {
        HStack {
           Rectangle()
                .frame(width: 30)
                .foregroundColor(.red)
                .cornerRadius(8, corners: [.topLeft, .bottomLeft])
                
            VStack(spacing: 10){
                HStack{
                    VStack(alignment: .leading){
                        Text("VALORANT")
                            .bold()
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("10 Mans In-Houses")
                            .bold()
                            .font(.title3)
                    }
                    Spacer()
                    VStack(alignment: .trailing){
                        Text("Oct")
                            .bold()
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("09")
                            .bold()
                            .font(.title3)
                    }
                }
                HStack{
                    VStack(alignment: .center){
                        Text("Time")
                            .bold()
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("8:00PM")
                            .bold()
                            .font(.body)
                    }
                    Spacer()
                    VStack(alignment: .center){
                        Text("Players")
                            .bold()
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("9")
                            .bold()
                            .font(.body)
                    }
                    Spacer()
                    VStack(alignment: .center){
                        Text("Team")
                            .bold()
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Text("2")
                            .bold()
                            .font(.body)
                    }
                }
            }
            .padding(EdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 15))
        }
    }
}

struct EventListCell_Previews: PreviewProvider {
    static var previews: some View {
        EventListCell()
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
