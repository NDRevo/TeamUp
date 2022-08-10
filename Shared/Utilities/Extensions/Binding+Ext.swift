//
//  Binding+Ext.swift
//  TeamUp
//
//  Created by Noe  Duran on 7/6/22.
//

import SwiftUI

//MARK: https://stackoverflow.com/questions/70416299/swiftui-simplify-onchange-modifier-for-many-textfields
extension Binding {
    public func onChange(perform action: @escaping () -> Void) -> Self where Value : Equatable {
        .init(
            get: {
                self.wrappedValue
            },
            set: { newValue in
                guard self.wrappedValue != newValue else { return }
                
                self.wrappedValue = newValue
                action()
            }
        )
    }

    public func onChange(perform action: @escaping (_ newValue: Value) -> Void) -> Self where Value : Equatable {
        .init(
            get: {
                self.wrappedValue
            },
            set: { newValue in
                guard self.wrappedValue != newValue else { return }
                
                self.wrappedValue = newValue
                action(newValue)
            }
        )
    }
}
