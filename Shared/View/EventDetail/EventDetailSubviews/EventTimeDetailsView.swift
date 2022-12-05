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
        HStack(alignment: .center) {
            DetailItemView(viewModel: viewModel, textContent: viewModel.event.getTime, detailType: .time, selectionDate: $viewModel.editedEventStartDate)
            Spacer()
            DetailItemView(viewModel: viewModel, textContent: viewModel.event.getEventDetailDate, detailType: .date, selectionDate: $viewModel.editedEventStartDate)
            Spacer()
            DetailItemView(viewModel: viewModel, textContent: viewModel.event.getEndTime, detailType: .endTime, selectionDate: $viewModel.editedEventEndDate)
        }
        .frame(height: 65)
        .frame(maxWidth: 355)
        .padding(10)
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
    @ObservedObject var viewModel: EventDetailViewModel

    var textContent: String
    var detailType: DetailItem
    @Binding var selectionDate: Date

    var body: some View {
        VStack(alignment: .center, spacing: 10){
            HStack(spacing: 4){
                Image(systemName: detailType.getSystemImage())
                    .resizable()
                    .scaledToFit()
                    .frame(width: 15)
                    .foregroundColor(.blue)
                Text(detailType.getTextHeading())
                    .font(.callout)
            }
            if viewModel.isEditingEventDetails {
                DatePicker(selection: $selectionDate, in: viewModel.eventDateRange, displayedComponents: [detailType == .date ? .date : .hourAndMinute]) {}
                    .labelsHidden()
            } else {
                Text(textContent)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(.appBackground)
                    }
            }
        }
    }
}
