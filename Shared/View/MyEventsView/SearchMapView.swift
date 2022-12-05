//
//  SearchMapView.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/10/22.
//

import SwiftUI
import MapKit
import Combine

struct SearchMapView: View {
    @StateObject private var searchViewModel = SearchMapViewModel()
    @Binding var eventLocationTitle: String?
    @Binding var eventLocation: String

    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            List(searchViewModel.viewData) { item in
                VStack(alignment: .leading) {
                    Text(item.title)
                    Text(item.subtitle)
                        .foregroundColor(.secondary)
                }.onTapGesture {
                    eventLocationTitle = item.title
                    eventLocation = item.subtitle
                    dismiss()
                }
            }
            .searchable(text: $searchViewModel.searchText)
            .navigationTitle("Locations")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Dismiss") {dismiss()}
                }
            }
         }
    }

}

struct SearchMapView_Previews: PreviewProvider {
    static var previews: some View {
        SearchMapView(eventLocationTitle: .constant("Rutgers Esports Center"), eventLocation: .constant("Rutgers"))
    }
}
