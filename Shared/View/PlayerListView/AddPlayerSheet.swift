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
    
    @State var playerFirstName: String   = ""
    @State var game: Games          = .VALORANT
    @State var gameID: String       = ""
    @State var playerRank: String   = ""

    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List{
            Section{
                TextField("First Name", text: $playerFirstName)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.words)
            }

            Picker("Game", selection: $game) {
                ForEach(Games.allCases, id: \.self){ game in
                    Text(game.rawValue)
                }
            }
            .pickerStyle(.menu)
            
            TextField("Game ID", text: $gameID)
                .disableAutocorrection(true)
                .keyboardType(.twitter)
                .textInputAutocapitalization(.never)
            Picker("Rank", selection: $playerRank) {
                ForEach(eventsManager.getRanksForGame(game: game), id: \.self){ rank in
                    Text(rank)
                }
            }
            .pickerStyle(.inline)

            Section{
                Button {
                    createAndSavePlayer()
                    dismiss()
                } label: {
                    Text("Add Player")
                        .foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("Create Player")
    }
    
    func createPlayer() -> CKRecord{
        let playerRecord = CKRecord(recordType: RecordType.player)
        playerRecord[TUPlayer.kFirstName] = playerFirstName
        
        return playerRecord
    }
    
    func createAndSavePlayer(){
        let playerRecord = createPlayer()
        Task{
            do {
                let _ = try await CloudKitManager.shared.save(record: playerRecord)
            } catch {
                //Alert
            }
        }
    }
}

//struct AddPlayerSheet_Previews: PreviewProvider {
//    static var previews: some View {
//        AddPlayerSheet()
//    }
//}
