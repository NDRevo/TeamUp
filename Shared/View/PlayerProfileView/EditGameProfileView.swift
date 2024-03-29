//
//  EditGameProfileView.swift
//  TeamUp
//
//  Created by Noé Duran on 6/22/22.
//

import SwiftUI

//MARK: EditGameProfileView
//INFO: Sheet that is presented to edit player game profile and to add alias
struct EditGameProfileView: View {

    @EnvironmentObject var playerManager: PlayerManager
    @EnvironmentObject var eventsManager: EventsManager

    var gameProfile: TUPlayerGameProfile
    @State var gameID: String           = ""
    @State var gameRank: String         = ""
    @State var gameAliases: [String]    = ["",""]
    @State var isSavable: Bool          = false

    var body: some View {
        VStack{
            Form {
                TextField("Game ID", text: $gameID.onChange(perform: checkSavable))
                    .onChange(of: gameID) { _ in
                        gameID = String(gameID.prefix(25))
                    }
                
                if !gameProfile.gameRank.isEmpty {
                    Picker("Rank", selection: $gameRank.onChange(perform: checkSavable)) {
                        ForEach(GameLibrary.data.getRanksForGame(for: gameProfile.gameName, with: gameProfile.gameVariantName)){ rank in
                            Text(rank.rankName)
                        }
                    }
                }

                Section {
                    TextField("Alias #1", text: $gameAliases[0].onChange(perform: checkSavable))
                        .onChange(of: gameAliases[0]) { _ in
                            gameAliases[0] = String(gameAliases[0].prefix(25))
                        }
                    TextField("Alias #2", text: $gameAliases[1].onChange(perform: checkSavable))
                        .onChange(of: gameAliases[1]) { _ in
                            gameAliases[1] = String(gameAliases[1].prefix(25))
                        }
                }

                Section {
                    if isSavable {
                        Button {
                            Task{
                                await playerManager.saveEditGameProfile(of: gameProfile, gameID: gameID, gameRank: gameRank, gameAliases: gameAliases)
                            }
                        } label: {
                            Text("Save Game Profile")
                        }
                    }
                    Button(role: .destructive) {
                        Task { await playerManager.deleteGameProfile(for: gameProfile) }
                    } label: {
                        Text("Delete Game Profile")
                    }
                }
            }
        }
        .keyboardType(.twitter)
        .disableAutocorrection(true)
        .replaceDisabled()
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Dismiss") { playerManager.isEditingGameProfile = false }
            }
        }
        .onAppear {
            gameID = gameProfile.gameID
            gameRank = gameProfile.gameRank
            if let gameAliases = gameProfile.gameAliases {
                self.gameAliases = gameAliases
            }
        }
        .navigationTitle("Edit")
    }

    func checkSavable() {
        if !gameID.isEmpty {
            if gameRank != gameProfile.gameRank {
                isSavable = true
            } else if gameID != gameProfile.gameID {
                isSavable = true
            } else if let gameAliases = gameProfile.gameAliases {
                if gameAliases[0] != self.gameAliases[0] {
                    isSavable = true
                } else if gameAliases[1] != self.gameAliases[1] {
                    isSavable = true
                }
            } else if !gameAliases[0].isEmpty || !gameAliases[1].isEmpty {
                isSavable = true
            }
            else {
                isSavable = false
            }
        } else {
            isSavable = false
        }
    }
}

struct EditGameProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditGameProfileView(gameProfile: TUPlayerGameProfile(record: MockData.playerGameProfile))
    }
}
