//
//  AddTeamSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

//MARK: AddTeamSheet
//INFO: Displays a sheet allowing you to name and add a team to the match
struct AddTeamSheet: View {

    @ObservedObject var viewModel: MatchDetailViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        List{
            TextField(text: $viewModel.teamName) {
                Text(viewModel.teamName.isEmpty ? "Team Name" : viewModel.teamName)
            }
            .font(.system(.body, design: .rounded, weight: .regular))
            .disableAutocorrection(true)
            .textInputAutocapitalization(.words)
            .onChange(of: viewModel.teamName) { _ in
                viewModel.teamName = String(viewModel.teamName.prefix(25))
            }
            Section{
                Button {
                    Task{ viewModel.createAndSaveTeam() }
                } label: {
                    Text("Add Team")
                        .font(.system(.body, design: .rounded, weight: .regular))
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Add Team")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Dismiss") {dismiss()}
            }
        }
        .alert($viewModel.isShowingAlert, alertInfo: viewModel.alertItem)
    }
}

struct AddTeamSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddTeamSheet(viewModel: MatchDetailViewModel(match: TUMatch(record: MockData.match), event: TUEvent(record: MockData.event)))
    }
}
