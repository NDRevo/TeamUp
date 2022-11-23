//
//  SchoolConstants.swift
//  TeamUp
//
//  Created by Noé Duran on 8/13/22.
//

import Foundation

//MARK: SchoolLibrary
//INFO: Singleton containing list of supported schools
final class SchoolLibrary {
    static let data = SchoolLibrary()
    
    let schools: [String] = [
        Constants.none,
        "Rutgers University - NBW",
        "Rutgers University - NWK",
        "Rutgers University - CDN"
    ]
}
