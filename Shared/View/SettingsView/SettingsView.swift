//
//  SettingsView.swift
//  TeamUp
//
//  Created by Noé Duran on 8/5/22.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject var viewModel = SettingsViewModel()
    @EnvironmentObject var eventsManager: EventsManager
    

    var body: some View {
        List {
            Button {
                viewModel.changeGameLeaderPosition(to: 2)
            } label: {
                Text(eventsManager.userProfile?.isGameLeader == 2 ? "Requested Game Leader" : "Request Game Leader")
            }
            .disabled(eventsManager.userProfile?.isGameLeader == 2 || eventsManager.userProfile?.isGameLeader == 1)
            
            
            Button(role: .destructive) {
                viewModel.changeGameLeaderPosition(to: 0)
            } label: {
                Text("Remove Game Leader Role")
            }
            //Add revoke

        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
