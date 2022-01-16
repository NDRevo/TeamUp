//
//  LoadingView.swift
//  TeamUp
//
//  Created by Noé Duran on 1/15/22.
//

import SwiftUI

struct LoadingView: View {

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .opacity(0.90)
                .ignoresSafeArea()
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                .scaleEffect(2)
                .offset(y: -40)
            
        }
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
