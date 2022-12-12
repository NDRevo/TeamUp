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
        VStack(spacing: 0) {
            HStack {
                Text("Create Match")
                    .foregroundColor(.primary)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                Spacer()
            }
            .padding(.horizontal, appHorizontalViewPadding)
            List {
                TextField("Match Name", text: $viewModel.matchName)
                    .font(.system(.body, design: .rounded, weight: .regular))
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .onChange(of: viewModel.matchName) { _ in
                        viewModel.matchName = String(viewModel.matchName.prefix(25))
                    }
                    .listRowBackground(Color.appCell)

                ///Bug:  **Causes UI contraint bugs
                DatePicker(selection: $viewModel.matchDate, in: viewModel.dateRange(), displayedComponents: [.hourAndMinute]){
                    Text("Match Date")
                        .font(.system(.body, design: .monospaced, weight: .medium))
                }
                .listRowBackground(Color.appCell)

                Section{
                    Button {
                        Task { viewModel.createMatchForEvent() }
                    } label: {
                        Text("Create Match")
                            .font(.system(.body, design: .rounded, weight: .regular))
                            .foregroundColor(.blue)
                    }
                }
                .listRowBackground(Color.appCell)
            }
            .scrollContentBackground(.hidden)
            
        }
        .background {
            Color.appBackground.ignoresSafeArea()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Dismiss") {dismiss()}
            }
        }
        .alert($viewModel.isShowingAddMatchSheetAlert, alertInfo: viewModel.alertItem)
    }
}

struct AddMatchSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddMatchSheet(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)))
    }
}
