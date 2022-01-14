//
//  AddTeamSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct AddTeamSheet: View {
    
    @Binding var teamName: String
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        List{
            TextField("Team Name", text: $teamName)
                .disableAutocorrection(true)
                .textInputAutocapitalization(.words)
            Section{
                Button {
                    //players.append(TUTeam(name: teamName))
                    dismiss()
                } label: {
                    Text("Add Team")
                        .foregroundColor(.blue)
                }
            }
        }
    }
}

struct AddTeamSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddTeamSheet(teamName: .constant("Team"))
    }
}
