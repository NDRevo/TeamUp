//
//  AddMatchSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI
import CloudKit

//MARK: AddMatchSheet
//INFO: Displays a sheet to input a match name and date and create the match
struct AddMatchSheet: View {

    @ObservedObject var viewModel: EventDetailViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        List{
            TextField("Match Name", text: $viewModel.matchName)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.words)

            ///Bug:  **Causes UI contraint bugs
            DatePicker("Match Date", selection: $viewModel.matchDate, in: viewModel.dateRange(), displayedComponents: [.hourAndMinute])

            Section{
                Button {
                    Task {
                        viewModel.createMatchForEvent()
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
        .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
            viewModel.alertItem.alertMessage
        })
    }
}

struct AddMatchSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddMatchSheet(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)))
    }
}
