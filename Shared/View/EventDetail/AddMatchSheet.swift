//
//  AddMatchSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI
import CloudKit

struct AddMatchSheet: View {
    
    @ObservedObject var viewModel: EventDetailViewModel

    var eventID: CKRecord.ID

    @Environment(\.dismiss) var dismiss
    
    let dateRange: PartialRangeFrom<Date> = {
        let date = Date()
        let calendar = Calendar.current
        let startDate = DateComponents(
            year: calendar.component(.year, from: date),
            month: calendar.component(.month, from: date),
            day: calendar.component(.day, from: date)
        )
        return calendar.date(from:startDate)!...
    }()
    
    var body: some View {
        List{
            TextField("Match Name", text: $viewModel.matchName)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.words)

            DatePicker("Match Date", selection: $viewModel.matchDate, in: dateRange, displayedComponents: [.hourAndMinute])
            
            Section{
                Button {
                    viewModel.createMatchForEvent(for: eventID)
                    dismiss()
                } label: {
                    Text("Create Match")
                        .foregroundColor(.blue)
                }
            }
        }
        .toolbar { Button("Dismiss") { dismiss() } }
        .navigationTitle("Create Match")
    }
}

struct AddMatchSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddMatchSheet(viewModel: EventDetailViewModel(), eventID: MockData.event.recordID)
    }
}
