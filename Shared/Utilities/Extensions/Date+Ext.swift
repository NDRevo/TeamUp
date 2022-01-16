//
//  Date+Ext.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import Foundation

extension Date {
    func convertDateToString() -> String {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        return timeFormatter.string(from: self)
    }
}
