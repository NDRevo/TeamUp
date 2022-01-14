//
//  AddAdminSheet.swift
//  TeamUp
//
//  Created by Noé Duran on 1/13/22.
//

import SwiftUI

struct AddAdminSheet: View {

    @Environment(\.dismiss) var dismiss

    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
            .toolbar { Button("Dismiss") { dismiss() } }
            .navigationTitle("Add Admin")
    }
}

struct AddAdminSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddAdminSheet()
    }
}
