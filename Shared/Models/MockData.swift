//
//  MockData.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct MockData {
    static var Matches: [TUMatch] {
        var matches: [TUMatch] = []
        matches.append(TUMatch(date: Date(), name: "Immortal"))
        matches.append(TUMatch(date: Date(), name: "Diamond"))
        matches.append(TUMatch(date: Date(), name: "Randoms"))
        return matches
        
    }
}
