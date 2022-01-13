//
//  TUEvent.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import Foundation

struct TUEvent {

    let startDate: Date
    let eventName: String

    var convertedDateToString: String {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        return timeFormatter.string(from: startDate)
    }

    init(date: Date, name: String){
        startDate  = date
        eventName  = name
    }
}
