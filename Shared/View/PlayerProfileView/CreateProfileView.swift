//
//  CreateProfileView.swift
//  TeamUp
//
//  Created by Noé Duran on 2/10/22.
//

import SwiftUI
import CloudKit

struct CreateProfileView: View {

    @EnvironmentObject var eventsManager: EventsManager
    @ObservedObject var viewModel: PlayerProfileViewModel

    var body: some View {
        List{
            Section{
                TextField("Username", text: $viewModel.playerUsername)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                TextField("First Name", text: $viewModel.playerFirstName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                TextField("Last Name", text: $viewModel.playerLastName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
            }
            Section {
                Button {
                    Task{
                        await viewModel.createProfile()
                    }
                } label: {
                    Text("Create Profile")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Create Profile")
        .alert(viewModel.alertItem.alertTitle, isPresented: $viewModel.isShowingAlert, actions: {}, message: {
            viewModel.alertItem.alertMessage
        })
    }
}

struct CreateProfileView_Previews: PreviewProvider {
    static var previews: some View {
       CreateProfileView(viewModel: PlayerProfileViewModel())
            .environmentObject(EventsManager())
    }
}
