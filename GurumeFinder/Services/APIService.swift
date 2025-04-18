//
//  APIService.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/06.
//

import Foundation
import CoreLocation

// MARK: - APIService 概要
// ホットペッパーグルメAPIとの通信を担当するサービスクラスです。
// シングルトンとして設計されており、アプリケーション内で唯一のインスタンスを共有します。
// レストランの検索や詳細情報の取得などのAPIリクエストを送信し、
// 受け取ったJSONレスポンスを Swift のモデルオブジェクトにデコードします。
// エラーハンドリングやログ出力も行います。

@Observable
class APIService {
    // MARK: - シングルトンインスタンス
    // APIService の唯一のインスタンスを共有するための静的プロパティ。
    static let shared = APIService()
    // 外部からのインスタンス化を禁止するためのプライベートイニシャライザ。
    private init() {}

    // MARK: - API 設定
    // ホットペッパーグルメAPIのベースURL。
    private let baseURL = "https://webservice.recruit.co.jp/hotpepper/gourmet/v1/"
    // APIキーを Info.plist から読み込むプライベートな計算型プロパティ。
    private let apiKey: String = {
        // Info.plist から 'HOTPEPPER_API_KEY' を取得し、String 型にキャストします。
        guard let key = Bundle.main.object(forInfoDictionaryKey: "HOTPEPPER_API_KEY") as? String, !key.isEmpty else {
            // APIキーが見つからないか空の場合、致命的なエラーとしてプログラムを停止させます。
            // preconditionFailure はデバッグビルドでのみチェックされ、リリースビルドでは無視されます。
            preconditionFailure("APIキーが見つからないか空です。Info.plistに 'HOTPEPPER_API_KEY' キーが設定され、xcconfig経由で値が正しく渡されているか確認してください。")
        }
        // デバッグビルドの場合、APIキーが読み込まれたことをログ出力します。
#if DEBUG
        print("🔑 APIキーを Info.plist から読み込みました。 Key: HOTPEPPER_API_KEY")
#endif
        return key // 読み込んだ APIキーを返します。
    }() // クロージャを定義と同時に実行し、apiKey に値を設定します。

    // MARK: - レストラン検索 API 呼び出し
    // 指定された緯度、経度、検索範囲、追加パラメータに基づいてレストランを検索する非同期関数。
    // 成功した場合は [Restaurant] 型の配列を返し、失敗した場合はエラーをスローします。
    func searchRestaurants(lat: Double, lng: Double, radius: Int, additionalParams: [String: String] = [:]) async throws -> [Restaurant] {
        // APIリクエストのクエリパラメータを格納する配列。
        var queryItems = [
            URLQueryItem(name: "key", value: apiKey), // APIキー
            URLQueryItem(name: "lat", value: String(lat)), // 緯度
            URLQueryItem(name: "lng", value: String(lng)), // 経度
            URLQueryItem(name: "range", value: String(radius)), // 検索範囲 (1: 300m, 2: 500m, 3: 1km, 4: 2km, 5: 3km)
            URLQueryItem(name: "format", value: "json"), // レスポンス形式を JSON に指定
            URLQueryItem(name: "count", value: "100") // 取得する店舗数 (最大 100)
        ]

        // 追加の検索パラメータをクエリに追加します。
        for (key, value) in additionalParams {
            queryItems.append(URLQueryItem(name: key, value: value))
        }

        // ベースURLにクエリパラメータを付与して URLComponents を作成します。
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = queryItems

        // 作成した URL から URLRequest を生成します。
        let request = URLRequest(url: urlComponents.url!)

        // リクエストURLをログ出力し、デバッグを容易にします。
        print("🔍 リクエストURL: \(request.url?.absoluteString ?? "不明")")

        // URLSession を使用して API リクエストを送信し、データとレスポンスを受け取ります (非同期処理)。
        let (data, response) = try await URLSession.shared.data(for: request)

        // レスポンスが HTTPURLResponse 型であることを確認し、ステータスコードをログ出力します。
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 ステータスコード: \(httpResponse.statusCode)")
        }

        // レスポンスデータを JSON 文字列としてログ出力 (デバッグ用、通常はコメントアウト)。
        //        if let jsonString = String(data: data, encoding: .utf8) {
        //            print("📥 レスポンスデータ: \(jsonString)")
        //        }

        // 受け取った JSON データを RestaurantResponse 型にデコードします。
        let decoded = try JSONDecoder().decode(RestaurantResponse.self, from: data)

        // デコードされたレスポンスから取得した店舗数をログ出力します。
        print("🍽 取得した店舗数: \(decoded.results.shop.count)")

        // デコードされたレスポンス内の店舗リストを返します。
        return decoded.results.shop
    }

    // MARK: - レストラン詳細情報 API 呼び出し
    // 指定された店舗 ID のレストラン詳細情報を取得する非同期関数。
    // 成功した場合は Restaurant 型のオブジェクトを返し、失敗した場合はエラーをスローします。
    func getRestaurantDetail(id: String) async throws -> Restaurant {
        // APIリクエストのクエリパラメータを格納する配列。
        let queryItems = [
            URLQueryItem(name: "key", value: apiKey), // APIキー
            URLQueryItem(name: "id", value: id), // 店舗 ID
            URLQueryItem(name: "format", value: "json") // レスポンス形式を JSON に指定
        ]

        // ベースURLにクエリパラメータを付与して URLComponents を作成します。
        var urlComponents = URLComponents(string: baseURL)!
        urlComponents.queryItems = queryItems

        // 作成した URL から URLRequest を生成します。
        let request = URLRequest(url: urlComponents.url!)

        // 店舗詳細リクエストの URL をログ出力します。
        print("🔍 店舗詳細リクエストURL: \(request.url?.absoluteString ?? "不明")")

        // URLSession を使用して API リクエストを送信し、データとレスポンスを受け取ります (非同期処理)。
        let (data, response) = try await URLSession.shared.data(for: request)

        // レスポンスが HTTPURLResponse 型であることを確認し、ステータスコードをログ出力します。
        if let httpResponse = response as? HTTPURLResponse {
            print("📡 店舗詳細ステータスコード: \(httpResponse.statusCode)")
        }

        // レスポンスデータを JSON 文字列としてログ出力 (デバッグ用、通常はコメントアウト)。
        //        if let jsonString = String(data: data, encoding: .utf8) {
        //            print("📥 店舗詳細レスポンスデータ: \(jsonString)")
        //        }

        // 受け取った JSON データを RestaurantResponse 型にデコードします。
        let decoded = try JSONDecoder().decode(RestaurantResponse.self, from: data)

        // デコードされたレスポンスから店舗情報が存在するか確認します。
        guard let restaurant = decoded.results.shop.first else {
            // 店舗詳細が見つからなかった場合、エラーをログ出力してスローします。
            print("❌ 店舗詳細が見つかりませんでした: ID \(id)")
            throw URLError(.badServerResponse)
        }

        // 店舗詳細の取得に成功したことをログ出力します。
        print("✅ 店舗詳細の取得に成功: \(restaurant.name)")

        // 取得したレストランの詳細情報を返します。
        return restaurant
    }

    // MARK: - デバッグ用メソッド
    // 受け取った Data を整形して JSON としてコンソールに出力するデバッグ用ヘルパーメソッド。
    func prettyPrintJSON(_ data: Data) {
        // JSONSerialization を使用して Data を JSON オブジェクトに変換します。
        if let json = try? JSONSerialization.jsonObject(with: data),
           // JSON オブジェクトを整形された JSON Data に変換します。
           let prettyData = try? JSONSerialization.data(withJSONObject: json, options: .prettyPrinted),
           // 整形された JSON Data を UTF-8 エンコーディングの String に変換して出力します。
           let prettyString = String(data: prettyData, encoding: .utf8) {
            print("🔄 整形されたJSON: \n\(prettyString)")
        } else {
            // JSON の整形に失敗した場合のエラーメッセージを出力します。
            print("❌ JSONの整形に失敗しました")
        }
    }

    // MARK: - デイニシャライザ (デバッグ用)
    // APIService のインスタンスが破棄される際に呼ばれるメソッド（シングルトンのため通常は呼ばれません）。
    deinit {
        print("✅ APIService が破棄されました")
    }
}
