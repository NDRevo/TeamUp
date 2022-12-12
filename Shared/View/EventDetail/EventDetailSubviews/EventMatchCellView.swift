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

    @ObservedObject var viewModel: EventDetailViewModel
    var match: TUMatch

    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: appHeaderToContentSpacing){
                HStack(alignment: .center, spacing: imageTextSpacing) {
                    Image(systemName: "clock")
                    Text(match.matchStartTime.convertDateToString())
                }
                .font(.system(.headline, design: .monospaced, weight: .medium))
                HStack{
                    Text(match.matchName)
                        .lineLimit(1)
                        .minimumScaleFactor(appMinimumScaleFactor)
                        .font(.system(.body, design: .rounded, weight: .bold))
                    Spacer()
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                //Adjust based on amount of events
                .background(Color.getGameColor(gameName: viewModel.event.eventGameName))
                .clipShape(RoundedRectangle(cornerRadius: appCornerRadius))
            }
        }
        .padding(appCellPadding)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: appCornerRadius))
        .frame(width: 200)
    }
}


struct EventMatchCellView_Previews: PreviewProvider {
    static var previews: some View {
        EventMatchCellView(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)),match: TUMatch(record: MockData.match))
    }
}
