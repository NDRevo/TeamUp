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

    @EnvironmentObject var playerManager: PlayerManager
    @FocusState private var currentFocus: FormFields?

    var body: some View {
        List {
            Section {
                TextField("Username", text: $playerManager.createdPlayerUsername)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.next)
                    .focused($currentFocus, equals: .username)
                    .onChange(of: playerManager.createdPlayerUsername) { _ in
                        playerManager.createdPlayerUsername = String(playerManager.createdPlayerUsername.prefix(25))
                    }
            } footer: { Text("Your username will be used for search and display purposes.") }

            Section {
                Picker("School", selection: $playerManager.createdPlayerSchool) {
                    ForEach(SchoolLibrary.data.schools, id: \.self){school in
                        Text(school)
                            .tag(school.self)
                    }
                }
                .pickerStyle(.menu)
            }

            Section{
                TextField("First Name", text: $playerManager.createdPlayerFirstName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.next)
                    .focused($currentFocus, equals: .firstName)
                    .onChange(of: playerManager.createdPlayerFirstName) { _ in
                        playerManager.createdPlayerFirstName = String(playerManager.createdPlayerFirstName.prefix(25))
                    }
                TextField("Last Name", text: $playerManager.createdPlayerLastName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
                    .submitLabel(.done)
                    .focused($currentFocus, equals: .lastName)
                    .onChange(of: playerManager.createdPlayerLastName) { _ in
                        playerManager.createdPlayerLastName = String(playerManager.createdPlayerLastName.prefix(25))
                    }
            } footer: {
                Text("Your name will not be viewable to anyone unless you want to display your name by changing your settings.")
            }
            Section {
                Button {
                    Task{ await playerManager.createProfile() }
                } label: {
                    Text("Create Profile")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Create Profile")
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
       CreateProfileView()
            .environmentObject(PlayerManager(iCloudRecord: MockData.player, playerProfile: TUPlayer(record: MockData.player)))
    }
}
