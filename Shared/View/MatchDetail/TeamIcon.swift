//
//  AddTeamIcon.swift
//  TeamUp
//
//  Created by Noé Duran on 3/19/22.
//

import SwiftUI

struct TeamIcon: View {
    
    var color: Color
    var isAdding: Bool
    
    var body: some View {
        ZStack(alignment: .bottomLeading){
            Image(systemName: "person.3")
                .font(.title2)
            Image(systemName: isAdding ? "plus.circle.fill" : "minus.circle.fill" )
                .foregroundStyle(.background, color)
                .offset(x: -8, y: 5)
                .font(.caption)
        }
        .foregroundColor(color)
        .offset(y: -2)
    }
}

struct TeamIcon_Previews: PreviewProvider {
    static var previews: some View {
        TeamIcon(color: .red, isAdding: true)
    }
}
