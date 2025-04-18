//
//  RestaurantSearchViewModel.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/18.
//

import Foundation

@Observable
class RestaurantSearchViewModel {
    let apiService = APIService()
    let locationManager = LocationManager()

    var restaurants: [Restaurant] = []
    var isLoading = false
    var error: Error?
    var radius: Int = 3
    var didPerformSearch = false

    // 共通の検索オプション
    let radiusOptions: [Int: String] = [
        1: "300m",
        2: "500m",
        3: "1km",
        4: "2km",
        5: "3km"
    ]

    // 位置情報リクエストメソッド
    func requestLocationPermission() {
        locationManager.requestPermission()
    }

    // 座標取得のヘルパーメソッド
    func getCoordinates() -> (Double, Double) {
        // 実際の位置情報が利用可能な場合はそれを使用
        if let location = locationManager.location {
            return (location.coordinate.latitude, location.coordinate.longitude)
        }

        // 位置情報が利用できない場合はダミーデータを返す
        return (35.6608183454, 139.7754267645)
    }
}
