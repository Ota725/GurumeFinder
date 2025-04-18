//
//  NearbyRestaurantsViewModel.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/18.
//

import Foundation

// MARK: - NearbyRestaurantsViewModel 概要
// 現在地周辺のレストランを検索し、表示するための ViewModel クラスです。
// 親クラスである RestaurantSearchViewModel の機能（位置情報の取得、API サービスとの連携など）を継承しています。
// @Observable マクロにより、プロパティの変更が SwiftUI View に自動的に通知されます。

@Observable
class NearbyRestaurantsViewModel: RestaurantSearchViewModel {
    // MARK: - 周辺のレストランを取得する関数
    // メインスレッドで非同期に現在地周辺のレストラン情報を取得します。
    @MainActor
    func fetchNearbyRestaurants() async {
        // 検索開始時にローディング状態を true に設定し、エラーを nil にリセットします。
        self.isLoading = true
        self.error = nil

        // 現在地の緯度経度を取得します。getCoordinates() は親クラス (RestaurantSearchViewModel) で定義されていると想定されます。
        let (lat, lng) = getCoordinates()

        // MARK: - API 呼び出しと結果処理
        do {
            // apiService を使用してレストラン検索 API を呼び出し、周辺のレストラン情報を取得します。
            // 親クラスから継承した radius プロパティで検索範囲を指定し、追加の検索条件は空の辞書 ([]) としています。
            let results = try await apiService.searchRestaurants(
                lat: lat,
                lng: lng,
                radius: radius,
                additionalParams: [:] // 追加の検索条件なし（現在地周辺のすべてのレストランを取得）
            )

            // 取得したレストラン情報を restaurants プロパティに格納し、ローディング状態を false に設定、検索実行フラグを true にします。
            self.restaurants = results
            self.isLoading = false
            self.didPerformSearch = true
        } catch {
            // エラーが発生した場合、error プロパティにエラー情報を格納し、ローディング状態を false に設定、restaurants を空の配列にします。
            self.error = error
            self.isLoading = false
            self.restaurants = []
        }
    }
}
