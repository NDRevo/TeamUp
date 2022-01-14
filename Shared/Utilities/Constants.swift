//
//  Constants.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

enum Games: String, CaseIterable{
    case overwatch    = "Overwatch"
    case apex         = "Apex Legends"
    case VALORANT     = "VALORANT"
}

enum RecordType{
    static let event             = "TUEvent"
    static let match             = "TUMatch"
    static let team              = "TUTeam"
    static let player            = "TUPlayer"
    static let playerGameDetails = "TUPlayGameDetails"
}
