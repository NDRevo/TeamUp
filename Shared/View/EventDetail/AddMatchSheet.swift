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

    var event: TUEvent

    @Environment(\.dismiss) var dismiss
  
    var body: some View {
        List{
            TextField("Match Name", text: $viewModel.matchName)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.words)

            DatePicker("Match Date", selection: $viewModel.matchDate, in: viewModel.dateRange(from: event), displayedComponents: [.hourAndMinute])
            
            Section{
                Button {
                    viewModel.createMatchForEvent(for: event.id)
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
        AddMatchSheet(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)), event: TUEvent(record: MockData.event))
    }
}
