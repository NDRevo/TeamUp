//
//  MatchOptionButtons.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/12/22.
//

import SwiftUI

//MARK: MatchOptionButtons
//INFO: Two buttons in an HStack that allow you to either shuffle or balance the teams
struct MatchOptionButtons: View {

    @ObservedObject var viewModel: MatchDetailViewModel

    var body: some View {
        HStack(spacing: 20) {
            Button(action: {
                viewModel.shufflePlayers()
            }, label: {
                Text("Shuffle")
            })
            .modifier(MatchDetailButtonStyle(color: .yellow))

            Button(action: {
                print("BALANCE")
            }, label: {
                Text("Balance")
            })
            .modifier(MatchDetailButtonStyle(color: .blue))
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .listRowBackground(Color.clear)
    }
}

struct MatchOptionButtons_Previews: PreviewProvider {
    static var previews: some View {
        MatchOptionButtons(viewModel: MatchDetailViewModel(match: TUMatch(record: MockData.match), event: TUEvent(record: MockData.event)))
    }
}
