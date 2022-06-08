//
//  AddPlayerSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI
import CloudKit

struct AddPlayerSheet: View {

    @EnvironmentObject var eventsManager: EventsManager
    @ObservedObject var viewModel: PlayerListViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        List{
            Section{
                TextField("First Name", text: $viewModel.playerFirstName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                TextField("Last Name", text: $viewModel.playerLastName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
            } header: {
                Text("General")
            }
            Section {
                Button {
                    dismiss()
                    Task{
                        viewModel.createAndSavePlayer(for: eventsManager)
                    }
                } label: {
                    Text("Add Player")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Create Player")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("Dismiss") {dismiss()}
            }
        }
    }
}

//struct AddPlayerSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        AddPlayerSheet()
//    }
//}
