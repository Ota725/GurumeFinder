//
//  RestaurantSearchViewModel.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/18.
//

import Foundation

// MARK: - RestaurantSearchViewModel 概要
// レストラン検索機能の基盤となる ViewModel クラスです。
// API サービスとの連携、位置情報の管理、検索状態の保持など、
// 複数の View で共通して利用される機能を提供します。
// @Observable マクロにより、プロパティの変更が SwiftUI View に自動的に通知されます。

@Observable
class RestaurantSearchViewModel {
    // MARK: - 依存性の注入
    // レストラン検索を行うための API サービスクラスのインスタンス。シングルトンとして共有されます。
    let apiService = APIService.shared
    // 位置情報を管理するための LocationManager クラスのインスタンス。
    let locationManager = LocationManager()

    // MARK: - 検索結果と状態
    // 検索結果として取得したレストランの配列。初期値は空の配列。
    var restaurants: [Restaurant] = []
    // データ読み込み中かどうかを示すフラグ。
    var isLoading = false
    // 発生したエラーを保持する変数。
    var error: Error?
    // 検索範囲（半径）をメートル単位で保持する変数。初期値は 3km。
    var radius: Int = 3
    // 検索が実行されたかどうかを示すフラグ。主に初回ローディングの制御などに使用。
    var didPerformSearch = false

    // MARK: - 検索オプション
    // 検索範囲の選択肢と、その表示名（メートル単位）の辞書。
    let radiusOptions: [Int: String] = [
        1: "300m",
        2: "500m",
        3: "1km",
        4: "2km",
        5: "3km"
    ]

    // MARK: - 位置情報関連メソッド
    // 位置情報の利用許可をリクエストするメソッド。LocationManager のメソッドを呼び出します。
    func requestLocationPermission() {
        locationManager.requestPermission()
    }

    // 現在地の座標を取得するヘルパーメソッド。
    // 位置情報が利用可能な場合は実際の位置情報を返し、
    // そうでない場合はデフォルトのダミー座標（東京駅付近）を返します。
    func getCoordinates() -> (Double, Double) {
        // LocationManager に保存されている最新の位置情報が存在する場合。
        if let location = locationManager.location {
            // その位置情報の緯度と経度をタプルで返します。
            return (location.coordinate.latitude, location.coordinate.longitude)
        }

        // 位置情報がまだ取得できていない場合や、何らかの理由で利用できない場合は、
        // 開発やテストのためにデフォルトの緯度経度を返します（例：東京駅）。
        return (35.6608183454, 139.7754267645)
    }
}
