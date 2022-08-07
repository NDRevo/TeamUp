//
//  CreateProfileView.swift
//  TeamUp
//
//  Created by Noé Duran on 2/10/22.
//

import SwiftUI
import CloudKit

enum FormFields {
    case username,firstName,lastName
}

struct CreateProfileView: View {

    @EnvironmentObject var eventsManager: EventsManager
    @ObservedObject var viewModel: PlayerProfileViewModel
    @FocusState private var currentFocus: FormFields?

    var body: some View {
        Form {
            Section {
                TextField("Username", text: $viewModel.playerUsername)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.next)
                    .focused($currentFocus, equals: .username)
            } footer: {
                Text("Your username will be used for search and display purposes.")
            }
            Section{
                TextField("First Name", text: $viewModel.playerFirstName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.next)
                    .focused($currentFocus, equals: .firstName)
                TextField("Last Name", text: $viewModel.playerLastName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .focused($currentFocus, equals: .lastName)
            } footer: {
                Text("Your name will not be viewable to anyone unless you want to display your name by changing your settings.")
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
        .onSubmit {
            switch currentFocus {
                case .username: currentFocus = .firstName
                case .firstName: currentFocus = .lastName
                case .lastName: currentFocus = nil
                case nil:
                    currentFocus = nil
                }
        }
    }
}

struct CreateProfileView_Previews: PreviewProvider {
    static var previews: some View {
       CreateProfileView(viewModel: PlayerProfileViewModel())
            .environmentObject(EventsManager())
    }
}
