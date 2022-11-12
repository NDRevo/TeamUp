//
//  NoiCloudView.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/12/22.
//

import SwiftUI

struct NoiCloudView: View {
    var body: some View {
        VStack(spacing: 25){
            Image(systemName: "bolt.horizontal.icloud.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 45)
            Text("Sign into iCloud to create and use a TeamUp account")
                .bold()
                .font(.body)
                .multilineTextAlignment(.center)
        }
        .padding(32)
    }
}

struct NoiCloudView_Previews: PreviewProvider {
    static var previews: some View {
        NoiCloudView()
    }
}
