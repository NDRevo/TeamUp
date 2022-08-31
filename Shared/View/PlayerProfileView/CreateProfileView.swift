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

//MARK: CreateProfileView
//INFO: First view seen when creating a profile. Username, School,and  First and Last Name are needed to create profile
struct CreateProfileView: View {

    @ObservedObject var viewModel: PlayerProfileViewModel
    @FocusState private var currentFocus: FormFields?

    var body: some View {
        List {
            Section {
                TextField("Username", text: $viewModel.playerUsername)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.next)
                    .focused($currentFocus, equals: .username)
                    .onChange(of: viewModel.playerUsername) { _ in
                        viewModel.playerUsername = String(viewModel.playerUsername.prefix(25))
                    }
            } footer: { Text("Your username will be used for search and display purposes.") }

            Section {
                Picker("School", selection: $viewModel.playerSchool) {
                    ForEach(SchoolLibrary.data.schools, id: \.self){school in
                        Text(school)
                            .tag(school.self)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            Section{
                TextField("First Name", text: $viewModel.playerFirstName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.next)
                    .focused($currentFocus, equals: .firstName)
                    .onChange(of: viewModel.playerFirstName) { _ in
                        viewModel.playerFirstName = String(viewModel.playerFirstName.prefix(25))
                    }
                TextField("Last Name", text: $viewModel.playerLastName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .focused($currentFocus, equals: .lastName)
                    .onChange(of: viewModel.playerLastName) { _ in
                        viewModel.playerLastName = String(viewModel.playerLastName.prefix(25))
                    }
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
