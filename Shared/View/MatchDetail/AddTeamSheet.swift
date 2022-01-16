//
//  AddTeamSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

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
                    viewModel.createAndSaveTeam()
                    dismiss()
                } label: {
                    Text("Add Team")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Add Team")
        .toolbar { Button("Dismiss") { dismiss() } }
    }
}

struct AddTeamSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddTeamSheet(viewModel: MatchDetailViewModel(match: TUMatch(record: MockData.match)))
    }
}
