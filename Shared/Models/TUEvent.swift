//
//  TUEvent.swift
//  TeamUp
//
//  Created by Noé Duran on 1/10/22.
//

import SwiftUI

struct TUEvent: Identifiable {
    var id = UUID()

    let startDate: Date
    let eventName: String
    var game: Games

    init(date: Date, name: String, game: Games){
        startDate  = date
        eventName  = name
        self.game = game
    }
    
    
    var getDateDetails: DateComponents {
        let calendar = Calendar.current
        let dateDetails = DateComponents(
        year: calendar.component(.year, from: startDate),
        month: calendar.component(.month, from: startDate),
        day: calendar.component(.day, from: startDate)
        )
    
        return dateDetails
    }
    
    func getMonth() -> String {
         let dateFormatter = DateFormatter()
         dateFormatter.dateFormat = "LLL"
         return dateFormatter.string(from: startDate)
    }
    
    func getTime() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        return dateFormatter.string(from: startDate)
   }
    
    func getGameColor() -> Color{
        switch game {
        case .overwatch:
            return .yellow
        case .apex:
            return .red
        case .VALORANT:
            return .red
        }
    }
}
