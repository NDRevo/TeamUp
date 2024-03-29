//
//  EventEditGameView.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 12/9/22.
//

import SwiftUI

struct EditGameView: View {
    @ObservedObject var viewModel: EventDetailViewModel

    var body: some View {
        VStack(spacing: 0){
            HStack {
                HStack(spacing: imageTextSpacing){
                    Image(systemName: "gamecontroller")
                        .font(.headline)
                        .foregroundColor(.blue)
                    Text("Game")
                        .font(.system(.body, design: .monospaced, weight: .medium))
                }
                Spacer()
                Picker("", selection: $viewModel.editedEventGame) {
                    //Starts from 2 to remove "All" & other case
                    ForEach(GameLibrary.data.games[1...]){game in
                        Text(game.name)
                            .tag(game.self)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                .font(.system(.body, design: .rounded, weight: .regular))
            }

            if viewModel.editedEventGame.hasVariants() {
                HStack {
                    Text("Variant")
                        .font(.system(.body, design: .monospaced, weight: .medium))
                    Spacer()
                    Picker("Variant", selection: $viewModel.editedEventGameVariant) {
                        ForEach(viewModel.editedEventGame.gameVariants){ game in
                            Text(game.name)
                                .tag(game.self)
                        }
                    }
                    .pickerStyle(.menu)
                    .labelsHidden()
                    .font(.system(.body, design: .rounded, weight: .regular))
                }
            }

            if viewModel.editedEventGame.name == GameNames.other {
                TextField("Game Name", text: $viewModel.userInputEditedEventGameName)
                    .font(.system(.body, design: .rounded, weight: .regular))
                    .autocorrectionDisabled()
                    .replaceDisabled()
            }
        }
        .padding(appCellPadding)
        .background(Color.appCell)
        .clipShape(RoundedRectangle(cornerRadius: appCornerRadius))
        .onChange(of: viewModel.editedEventGame) { newGame in
            if !newGame.hasVariants(){
                viewModel.editedEventGameVariant = Game(name: GameNames.empty, ranks: [])
            } else {
                viewModel.editedEventGameVariant = newGame.gameVariants.first!
            }

            if newGame.name != GameNames.other {
                viewModel.userInputEditedEventGameName = ""
            }
        }
    }
}

struct EditGameView_Previews: PreviewProvider {
    static var previews: some View {
        EditGameView(viewModel: EventDetailViewModel(event: TUEvent(record: MockData.event)))
    }
}
