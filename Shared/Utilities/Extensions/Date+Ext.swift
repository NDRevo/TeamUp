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

    func distance(from date: Date, only component: Calendar.Component, calendar: Calendar = .current) -> Int {
        let days1 = calendar.component(component, from: self)
        let days2 = calendar.component(component, from: date)
        return days1 - days2
    }

    func hasSame(_ component: Calendar.Component, as date: Date) -> Bool {
        distance(from: date, only: component) == 0
    }
}
