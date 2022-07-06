//
//  AddMatchSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI
import CloudKit

struct AddMatchSheet: View {

    @EnvironmentObject var eventDetailManager: EventDetailManager
    @ObservedObject var viewModel: EventDetailViewModel

    @Environment(\.dismiss) var dismiss
  
    var body: some View {
        List{
            TextField("Match Name", text: $viewModel.matchName)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.words)

            DatePicker("Match Date", selection: $viewModel.matchDate, in: viewModel.dateRange(), displayedComponents: [.hourAndMinute])
            
            Section{
                Button {
                    Task {
                        dismiss()
                        try await Task.sleep(nanoseconds: 50_000_000)
                        viewModel.createMatchForEvent(eventDetailManager: eventDetailManager)
                    }
                } label: {
                    Text("Create Match")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Create Match")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Dismiss") {dismiss()}
            }
        }
    }
}

struct AddMatchSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddMatchSheet(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)))
    }
}
