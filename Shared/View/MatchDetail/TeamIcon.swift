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
            
            ZStack {
                Circle()
                    .strokeBorder(.background)
                    .background {
                        Circle().fill(color)
                    }
                    .frame(width: 14, height:  14)
                Image(systemName: isAdding ? "plus" : "minus" )
                    .foregroundStyle(.background, .background)
                    .font(.system(size: 7, weight: .bold, design: .default))
            }
            .offset( y: 2)
        }
        .frame(width: 48, height: 28)
        .foregroundColor(color)
        .offset( y: -1)
    }
}

struct TeamIcon_Previews: PreviewProvider {
    static var previews: some View {
        TeamIcon(color: .red, isAdding: true)
    }
}
