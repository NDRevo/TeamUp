//
//  MatchDetailButton.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI


struct MatchDetailButtonStyle: ViewModifier {
    var color: Color

    func body(content: Content) -> some View {
        content
            .buttonStyle(.bordered)
            .tint(color)
            .controlSize(.regular)
            .headerProminence(.increased)
    }
}
