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
    @ObservedObject var viewModel: DebugViewModel

    @Environment(\.dismiss) var dismiss

    var body: some View {
        List{
            Section{
                TextField("Username", text: $viewModel.playerUsername)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .onChange(of: viewModel.playerUsername) { _ in
                        viewModel.playerUsername = String(viewModel.playerUsername.prefix(25))
                    }
                TextField("First Name", text: $viewModel.playerFirstName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .onChange(of: viewModel.playerFirstName) { _ in
                        viewModel.playerFirstName = String(viewModel.playerFirstName.prefix(25))
                    }
                TextField("Last Name", text: $viewModel.playerLastName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .onChange(of: viewModel.playerLastName) { _ in
                        viewModel.playerLastName = String(viewModel.playerLastName.prefix(25))
                    }
            } header: {
                Text("General")
            }
            Section {
                Button {
                    viewModel.createAndSavePlayer(for: eventsManager)
                } label: {
                    Text("Add Player")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Create Player")
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

struct AddPlayerSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddPlayerSheet(viewModel: DebugViewModel())
            .environmentObject(EventsManager())
    }
}
