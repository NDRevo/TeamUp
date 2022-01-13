//
//  TUMatch.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import Foundation

struct TUMatch {

    static let kTime        = "time"

    let startTime: Date
    let endTime: Date?
    let desc: String

    var convertedDateToString: String {
        let timeFormatter = DateFormatter()
        timeFormatter.timeStyle = .short
        return timeFormatter.string(from: startTime)
    }

    init(date: Date, description: String){
        startTime  = date
        desc  = description
        endTime = nil
    }
}
