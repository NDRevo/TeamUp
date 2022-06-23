//
//  Color+Ext.swift
//  TeamUp
//
//  Created by Noé Duran on 1/24/22.
//

import SwiftUI

extension Color {

    static let appBackground = Color("appBackground")
    static let appCell       = Color("appCell")

    static let apexlegend               = Color(red: 164 / 255, green: 55 / 255, blue: 61 / 255)
    static let apexBottomGradient       = Color(red: 219 / 255, green: 72 / 255, blue: 81 / 255)
    
    static let overwatch                = Color(red: 249 / 255, green: 158 / 255, blue: 26 / 255)
    static let overwatchBottomGradient  = Color(red: 250 / 255, green: 187 / 255, blue: 94 / 255)
    
    static let valorant                 = Color(red: 189 / 255, green: 57 / 255, blue: 68 / 255)
    static let valorantBottomGradient   = Color(red: 253 / 255, green: 69 / 255, blue: 86 / 255)
    
    static func getGameColor(gameName: String) -> Color{
        switch gameName {
            case "Overwatch":
                return .overwatch
            case "Apex Legends":
                return .apexlegend
            case "VALORANT":
                return .valorant
            default:
                return .gray
        }
    }
    
    static func getGameColorGradient(gameName: String) -> Color{
        switch gameName {
            case "Overwatch":
                return .overwatchBottomGradient
            case "Apex Legends":
                return .apexBottomGradient
            case "VALORANT":
                return .valorantBottomGradient
            default:
                return .gray
        }
    }
    
}
