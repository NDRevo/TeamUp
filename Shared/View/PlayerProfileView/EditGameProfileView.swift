//
//  EditGameProfileView.swift
//  TeamUp
//
//  Created by Noé Duran on 6/22/22.
//

import SwiftUI

struct EditGameProfileView: View {
    
    @EnvironmentObject var eventsManager: EventsManager
    @ObservedObject var viewModel: PlayerProfileViewModel
    
    var gameProfile: TUPlayerGameProfile
    @State var gameID: String = ""
    @State var gameRank: String = ""
    @State var isSavable: Bool = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack{
            Form {
                TextField("Game ID", text: $gameID)
                Picker("Rank", selection: $gameRank) {
                    ForEach(eventsManager.getRanksForGame(game: Games(rawValue: gameProfile.gameName)!), id: \.self){ rank in
                        Text(rank)
                    }
                }
                Section {
                    if isSavable {
                        Button {
                            viewModel.saveEditGameProfile(of: gameProfile.id, gameID: gameID, gameRank: gameRank)
                            dismiss()
                        } label: {
                            Text("Save Game Profile")
                        }
                    }
                    Button(role: .destructive) {
                        viewModel.deleteGameProfile(for: gameProfile.id, eventsManager: eventsManager)
                    } label: {
                        Text("Delete Game Profile")
                    }
                }
            }
        }
        .onChange(of: gameRank, perform: { newValue in
            if gameRank != gameProfile.gameRank {
                isSavable = true
            } else {
                isSavable = false
            }
        })
        .onChange(of: gameID, perform: { newValue in
            if gameID != gameProfile.gameID {
                isSavable = true
            } else {
                isSavable = false
            }
        })
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Dismiss") {dismiss()}
            }
        }
        .onAppear {
            gameID = gameProfile.gameID
            gameRank = gameProfile.gameRank
        }
    }
}

struct EditGameProfileView_Previews: PreviewProvider {
    static var previews: some View {
        EditGameProfileView(viewModel: PlayerProfileViewModel(), gameProfile: TUPlayerGameProfile(record: MockData.playerGameProfile))
    }
}
