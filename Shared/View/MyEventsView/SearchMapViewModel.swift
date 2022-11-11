//
//  SearchMapViewModel.swift
//  TeamUp (iOS)
//
//  Created by Noé Duran on 11/10/22.
//

import Foundation
import MapKit
import Combine

struct LocalSearchViewData: Identifiable {
    var id = UUID()
    var title: String
    var subtitle: String

    init(mapItem: MKMapItem) {
        self.title = mapItem.name ?? ""
        self.subtitle = mapItem.placemark.title ?? ""
    }
}

final class SearchMapViewModel: ObservableObject {
    let localSearchPublisher = PassthroughSubject<[MKMapItem], Never>()
    private var cancellable: AnyCancellable?

    @Published var searchText = "" {
        didSet { request(searchText: searchText) }
    }

    @Published var viewData = [LocalSearchViewData]()

    init() {
        cancellable = localSearchPublisher.sink { mapItems in
            self.viewData = mapItems.map({ LocalSearchViewData(mapItem: $0) })
        }
    }

    func request(resultType: MKLocalSearch.ResultType = .pointOfInterest, searchText: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchText
        request.pointOfInterestFilter = .includingAll
        request.resultTypes = resultType
 
        let search = MKLocalSearch(request: request)

        search.start { [weak self](response, _) in
            guard let response = response else {
                return
            }

            self?.localSearchPublisher.send(response.mapItems)
        }
    }
}
