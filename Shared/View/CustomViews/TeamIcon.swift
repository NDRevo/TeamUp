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
                    .stroke(Color.appBackground, lineWidth: 1.5)
                    .background {
                        Circle()
                            .fill(color)
                        
                    }
                    .frame(width: 14, height:  14)
                Image(systemName: isAdding ? "plus" : "minus" )
                    .foregroundStyle(.background, .background)
                    .font(.system(size: 7, weight: .bold, design: .default))
            }
            .offset( y: 3)
        }
        .frame(width: 36, height: 22)
        .foregroundColor(color)
        .offset( y: -2)
    }
}

struct TeamIcon_Previews: PreviewProvider {
    static var previews: some View {
        TeamIcon(color: .red, isAdding: true)
    }
}
