//
//  GameCell.swift
//  TeamUp
//
//  Created by Noé Duran on 7/31/22.
//

import SwiftUI

struct GameCell: View {

    @EnvironmentObject private var eventsManager: EventsManager
    @ObservedObject var viewModel: EventsListViewModel
    var game: Games

    var body: some View {
        RoundedRectangle(cornerRadius: 8)
            .foregroundStyle(
                Color.getGameColor(gameName: game.rawValue)
            )
            .overlay{
                if game == .all {
                    Image(systemName: "rectangle.stack")
                        .font(.title)
                        .bold()
                } else {
                    Text(game.rawValue.prefix(1))
                        .font(.title)
                        .bold()
                }
                if game == viewModel.currentGameSelected {
                    RoundedRectangle(cornerRadius: 8)
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
        GameCell(viewModel: EventsListViewModel(), game: .none)
    }
}
