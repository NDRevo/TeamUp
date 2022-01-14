//
//  TUMatch.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import Foundation

struct TUMatch: Identifiable {
    var id = UUID()

    let startTime: Date
    let endTime: Date?
    var name: String

    init(date: Date, name: String){
        startTime  = date
        self.name  = name
        endTime = nil
    }
}
