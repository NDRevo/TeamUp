//
//  MenuBarGameCell.swift
//  TeamUp
//
//  Created by Noé Duran on 7/31/22.
//

import SwiftUI

struct MenuBarGameCell: View {

    @EnvironmentObject private var eventsManager: EventsManager
    @ObservedObject var viewModel: EventsListViewModel
    var game: Game

    let menuBarGameCellCornerRadius: CGFloat = 8

    var body: some View {
        RoundedRectangle(cornerRadius: menuBarGameCellCornerRadius )
            .foregroundStyle(
                game.gameColor
            )
            .overlay{
                if let image = game.image {
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35)
                        .foregroundColor(Color(.white))
                } else {
                    Text(game.name.prefix(1))
                        .font(.title)
                        .bold()
                }
                if game.name == viewModel.currentGameSelected.name {
                    RoundedRectangle(cornerRadius: menuBarGameCellCornerRadius)
                        .stroke(Color.appPrimaryInverse, lineWidth: 4)
                }
            }
            .frame(width: 55, height: 55)
            .onTapGesture {
                viewModel.currentGameSelected = game
                eventsManager.getPublicEvents(forGame: game)
            }
    }
}

struct GameCell_Previews: PreviewProvider {
    static var previews: some View {
        MenuBarGameCell(viewModel: EventsListViewModel(), game: GameLibrary.data.games.last!)
    }
}
