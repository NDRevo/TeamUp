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
                        viewModel.createProfile()
                    }
                } label: {
                    Text("Create Profile")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Create Profile")
    }
}
