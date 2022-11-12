//
//  EventMatchCellView.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/11/22.
//

import SwiftUI

//MARK: EventMatchCellView
//INFO: Event Match cell view
struct EventMatchCellView: View {

    var matchName: String
    var matchTime: String

    var body: some View {
        HStack(spacing: 32){
            VStack(alignment: .leading, spacing: 12){
                Text(matchName)
                    .foregroundColor(Color.appCell)
                    .bold()
                    .font(.title3)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    //Adjust based on amount of events
                    .background(.red)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                HStack {
                    Image(systemName: "calendar.badge.clock")
                    Text(matchTime)
                }
            }
            Image(systemName: "chevron.right")
        }
        .padding(.horizontal, 10)
        .padding(.vertical)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
