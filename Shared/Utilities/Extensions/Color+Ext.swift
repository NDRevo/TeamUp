//
//  Color+Ext.swift
//  TeamUp
//
//  Created by Noé Duran on 1/24/22.
//

import SwiftUI

extension Color {

    static let appPrimaryInverse    = Color("inversePrimary")
    static let appBackground        = Color("appBackground")
    static let appCell              = Color("appCell")

    static let apexlegend           = Color(red: 164 / 255, green: 55 / 255, blue: 61 / 255)
    static let overwatch            = Color(red: 249 / 255, green: 158 / 255, blue: 26 / 255)
    static let valorant             = Color(red: 189 / 255, green: 57 / 255, blue: 68 / 255)
    
    static func getGameColor(gameName: String) -> Color {
        switch gameName {
            case GameNames.overwatch:
                return .overwatch
            case GameNames.apexlegends:
                return .apexlegend
            case GameNames.valorant:
                return .valorant
            default:
                return .gray
        }
    }
}
