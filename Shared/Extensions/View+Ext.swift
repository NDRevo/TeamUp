//
//  View+Ext.swift
//  TeamUp
//
//  Created by Noé Duran on 1/11/22.
//

import SwiftUI

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
