//
//  EventMoreDetailSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 8/13/22.
//

import SwiftUI

//MARK: EventMoreDetailsSheet
//INFO: Displays a sheet with more details about the event: Owner Name, Event Game Name, School associated to Event
struct EventMoreDetailsSheet: View {
    
    @ObservedObject var viewModel: EventDetailViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List {
            MoreDetailItemView(textContent: viewModel.event.eventOwnerName, detailType: .owner)
            MoreDetailItemView(textContent: viewModel.event.eventGameName+viewModel.event.eventGameVariantName , detailType: .game)
            MoreDetailItemView(textContent: viewModel.event.eventSchool, detailType: .school)
            MoreDetailItemView(textContent: viewModel.event.eventSchoolClub, detailType: .clubHosting)
        }
    }
}


struct MoreDetailItemView: View {

    var textContent: String
    var detailType: DetailItem

    var body: some View {
        VStack(alignment: .leading, spacing: 5){
            HStack(spacing: 4){
                Image(systemName: detailType.getSystemImage())
                    .foregroundColor(.blue)
                Text(detailType.getTextHeading())
                    .font(.callout)
            }
            Text(textContent)
                .bold()
                .lineLimit(1)
                .minimumScaleFactor(0.75)
        }
    }
}


struct EventMoreDetailsSheet_Previews: PreviewProvider {
    static var previews: some View {
        EventMoreDetailsSheet(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)))
    }
}
