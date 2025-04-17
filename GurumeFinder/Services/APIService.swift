//
//  APIService.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/06.
//

import Foundation
import CoreLocation

class APIService {
    private let baseURL = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/"
    private let apiKey: String = {
        guard let key = Bundle.main.object(forInfoDictionaryKey: "HOTPEPPER_API_KEY") as? String, !key.isEmpty else {
            // fatalError の代わりに preconditionFailure を使用
            preconditionFailure("APIキーが見つからないか空です。Info.plistに 'HOTPEPPER_API_KEY' キーが設定され、xcconfig経由で値が正しく渡されているか確認してください。")
        }
#if DEBUG
        print("🔑 APIキーを Info.plist から読み込みました。 Key: HOTPEPPER_API_KEY")
#endif
        return key // クロージャからの戻り値
    }() // クロージャの即時実行

    func searchRestaurants(lat: Double, lng: Double, radius: Int, additionalParams: [String: String] = [:]) async throws -> [Restaurant] {
        var queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "lat", value: String(lat)),
            URLQueryItem(name: "lng", value: String(lng)),
            URLQueryItem(name: "range", value: String(radius)),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "count", value: "100")
        ]

        // 追加パラメータを追加
        for (key, value) in additionalParams {
            queryItems.append(URLQueryItem(name: key, value: value))
        }

        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = queryItems

        let request = URLRequest(url: urlComponents.url!)

        // リクエストURLをログ出力
        print("🔍 リクエストURL: \(request.url?.absoluteString ?? "不明")")

        let (data, response) = try await URLSession.shared.data(for: request)

        // レスポンスステータスをログ出力
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 ステータスコード: \(httpResponse.statusCode)")
        }

        // レスポンスデータをJSONとして出力
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print("📥 レスポンスデータ: \(jsonString)")
//        }

        // デコード
        let decoded = try JSONDecoder().decode(RestaurantResponse.self, from: data)

        // 取得した店舗数を出力
        print("🍽 取得した店舗数: \(decoded.results.shop.count)")

        return decoded.results.shop
    }

    func getRestaurantDetail(id: String) async throws -> Restaurant {
        let queryItems = [
            URLQueryItem(name: "key", value: apiKey),
            URLQueryItem(name: "id", value: id),
            URLQueryItem(name: "format", value: "json")
        ]

        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = queryItems

        let request = URLRequest(url: urlComponents.url!)

        // リクエストURLをログ出力
        print("🔍 店舗詳細リクエストURL: \(request.url?.absoluteString ?? "不明")")

        let (data, response) = try await URLSession.shared.data(for: request)

        // レスポンスステータスをログ出力
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 店舗詳細ステータスコード: \(httpResponse.statusCode)")
        }

        // レスポンスデータをJSONとして出力
//        if let jsonString = String(data: data, encoding: .utf8) {
//            print("📥 店舗詳細レスポンスデータ: \(jsonString)")
//        }

        // デコード
        let decoded = try JSONDecoder().decode(RestaurantResponse.self, from: data)

        guard let restaurant = decoded.results.shop.first else {
            print("❌ 店舗詳細が見つかりませんでした: ID \(id)")
            throw URLError(.badServerResponse)
        }

        print("✅ 店舗詳細の取得に成功: \(restaurant.name)")

        return restaurant
    }

    // JSONデコードのデバッグ用ヘルパーメソッド
    func prettyPrintJSON(_ data: Data) {
        if let json = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("🔄 整形されたJSON: \n\(prettyString)")
        } else {
            print("❌ JSONの整形に失敗しました")
        }
    }
}
