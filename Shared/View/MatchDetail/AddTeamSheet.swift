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
            TextField("Team Name", text: $viewModel.teamName)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.words)
            Section{
                Button {
                    Task{
                        dismiss()
                        try await Task.sleep(nanoseconds: 50_000_000)
                        viewModel.createAndSaveTeam()
                    }
                } label: {
                    Text("Add Team")
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
    }
}

struct AddTeamSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddTeamSheet(viewModel: MatchDetailViewModel(match: TUMatch(record: MockData.match), event: TUEvent(record: MockData.event)))
    }
}
