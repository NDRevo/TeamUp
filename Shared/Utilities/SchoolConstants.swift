//
//  SchoolConstants.swift
//  TeamUp
//
//  Created by Noé Duran on 8/13/22.
//

import Foundation

enum SchoolLibrary: String, CaseIterable {
    case none      = "None"
    case rutgersNB = "Rutgers University - New Brunswick"
    case rutgersNW = "Rutgers University - Newark"
    case rutgersCM = "Rutgers University - Camden"
    case stevensIT   = "Stevens Institute of Technology"
    
    func getVerificationLink() -> String {
        switch self {
        case .none : return ""
        case .rutgersCM,.rutgersNW,.rutgersNB: return "https://cas.rutgers.edu/login"
        case .stevensIT: return ""
        }
    }
    
}
