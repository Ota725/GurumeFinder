//
//  NearbyRestaurantsViewModel.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/18.
//

import Foundation

@Observable
class NearbyRestaurantsViewModel: RestaurantSearchViewModel {
    @MainActor
    func fetchNearbyRestaurants() async {
        self.isLoading = true
        self.error = nil

        let (lat, lng) = getCoordinates()

        do {
            let results = try await apiService.searchRestaurants(
                lat: lat,
                lng: lng,
                radius: radius,
                additionalParams: [:] // 条件なしで検索
            )

            self.restaurants = results
            self.isLoading = false
            self.didPerformSearch = true
        } catch {
            self.error = error
            self.isLoading = false
            self.restaurants = []
        }
    }
}
