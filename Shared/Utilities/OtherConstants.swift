//
//  OtherConstants.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

enum WordConstants {
    static let none = "None"
    static let discordgg = "discord.gg"
    static let eventDescription = "Event Description"
    static let address = "Address"
    static let addressTitle = "Address Title"
}

enum RecordType{
    static let event                = "TUEvent"
    static let match                = "TUMatch"
    static let team                 = "TUTeam"
    static let player               = "TUPlayer"
    static let playerGameProfiles   = "TUPlayerGameProfile"
}

var navigationTitleFont: UIFont {
    let design = UIFontDescriptor.SystemDesign.rounded
    var descriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .largeTitle).withDesign(design)!
    descriptor = descriptor.withSymbolicTraits(UIFontDescriptor.SymbolicTraits.traitBold)!
    let navigationtTitleFont = UIFont.init(descriptor: descriptor, size: 38)
    
    return navigationtTitleFont
}

let imageTextSpacing: CGFloat = 4
let appHorizontalViewPadding: CGFloat = 4
let appCornerRadius: CGFloat = 10
let appMinimumScaleFactor: CGFloat = 0.85
let appCellPadding: CGFloat = 10
let appHeaderToContentSpacing: CGFloat = 10
let appImageToTextEmptyContentSpacing: CGFloat = 12
let appCellSpacing: CGFloat = 8
let appImageSizeEmptyContent: CGFloat = 32
