//
//  UIColor+Ext.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/24/22.
//

import SwiftUI
import UIKit

extension Color {

    // MARK: - Initialization
    init(hexString:String) {
        var hexSanitized = hexString.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        let mask = 0x000000FF
        let r = Int(rgb >> 16) & mask
        let g = Int(rgb >> 8) & mask
        let b = Int(rgb) & mask

        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0

        self.init(red: red, green: green, blue: blue, opacity: 1)
    }

    func toHexString() -> String? {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0

        UIColor(self).getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0

        return String(format:"#%06x", rgb)
    }
}
