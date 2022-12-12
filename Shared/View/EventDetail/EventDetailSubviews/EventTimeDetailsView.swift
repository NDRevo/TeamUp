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

    @State var date = Date()
    var body: some View {
        HStack(alignment: .center, spacing: 4) {
            if !viewModel.isEditingEventDetails { EditEventDateView(viewModel: viewModel) }

            VStack(alignment:.leading,spacing: 5){
                if viewModel.isEditingEventDetails {
                    DetailItemView(viewModel: viewModel, textContent: viewModel.event.getEventDetailDate, detailType: .date, selectionDate: $viewModel.editedEventStartDate)
                }
                DetailItemView(viewModel: viewModel, textContent: viewModel.event.getTime, detailType: .time, selectionDate: $viewModel.editedEventStartDate)
                DetailItemView(viewModel: viewModel, textContent: viewModel.event.getEndTime, detailType: .endTime, selectionDate: $viewModel.editedEventEndDate)
            }
        }
        .frame(maxWidth: 365)
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
        HStack(alignment: .center){
            HStack(spacing: 4){
                Image(systemName: detailType.getSystemImage())
                    .font(.headline)
                    .foregroundColor(.blue)
                Text(detailType.getTextHeading())
                    .font(.system(.callout, design: .monospaced, weight: .medium))
            }
            Spacer()
            if viewModel.isEditingEventDetails {
                DatePicker(selection: $selectionDate, in: detailType == .endTime ? viewModel.eventEndDateRange : viewModel.eventDateRange, displayedComponents: [detailType == .date ? .date : .hourAndMinute]) {}
                    .scaleEffect(0.85)
                    .labelsHidden()
                    .onChange(of: viewModel.editedEventStartDate) { newValue in
                        if viewModel.editedEventEndDate <= newValue {
                            viewModel.editedEventEndDate = Calendar.current.date(byAdding: .hour, value: 1, to: newValue)!
                        }

                        let calendar = Calendar.current
                        let endDate = DateComponents(
                            year: calendar.component(.year, from: newValue),
                            month: calendar.component(.month, from: newValue),
                            day: calendar.component(.day, from: newValue),
                            hour: calendar.component(.hour, from: newValue)
//                          ,minute: calendar.component(.minute, from: newValue + (60*15))
                        )
                        viewModel.eventEndDateRange = calendar.date(from: endDate)!...
                    }
                    .onChange(of: viewModel.editedEventEndDate) { newValue in
                        if !viewModel.editedEventEndDate.hasSame(.day, as: viewModel.editedEventStartDate){
                            viewModel.editedEventEndDate = Calendar.current.date(byAdding: .hour, value: 1, to: viewModel.editedEventStartDate)!
                        }
                    }
                
            } else {
                HStack{
                    Text(textContent)
                        .font(.system(.body, design: .monospaced, weight: .bold))
                        .lineLimit(1)
                        .minimumScaleFactor(0.85)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .frame(width: 100)
                }
                .background {
                    RoundedRectangle(cornerRadius: 8)
                        .foregroundColor(.appBackground)
                }
            }
        }
        //Prevents from DatePicker from spreading out content
        .frame(maxHeight: 28)
    }
}

struct EditEventDateView: View {
    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        VStack(alignment: .center){
            VStack{
                Text("\(viewModel.event.getMonth)")
                    .font(.system(.body, design: .monospaced, weight: .medium))
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                Text("\(viewModel.event.getDateDetails.day!)")
                    .font(.system(.title, design: .monospaced, weight: .bold))
            }
            
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.appBackground)
        }
    }
}
