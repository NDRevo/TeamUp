//
//  EventTimeDetailsView.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/11/22.
//

import SwiftUI

//MARK: EventTimeDetailsView
//INFO: Displays DetailItemViews for date, start time, and end time.
struct EventTimeDetailsView: View {

    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        HStack(spacing: 5){
            DetailItemView(textContent: viewModel.event.getEventDetailDate, detailType: .date)
            Spacer()
            DetailItemView(textContent: viewModel.event.getTime, detailType: .time)
            Spacer()
            DetailItemView(textContent: viewModel.event.getEndTime, detailType: .endTime)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical)
        .padding(.horizontal, 10)
        .allowToPresentCalendar(with: viewModel)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

struct EventTimeDetailsView_Previews: PreviewProvider {
    static var previews: some View {
        EventTimeDetailsView(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)))
    }
}

//MARK: DetailItemView
//INFO: Reused view to display Image and Title on top of the detail item text
struct DetailItemView: View {

    var textContent: String
    var detailType: DetailItem

    var body: some View {
        VStack(alignment: .center, spacing: 5){
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
