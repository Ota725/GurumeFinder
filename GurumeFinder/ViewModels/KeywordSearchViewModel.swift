//
//  KeywordSearchViewModel.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/18.
//

import Foundation

// MARK: - KeywordSearchViewModel 概要
// キーワード検索機能に特化した ViewModel クラスです。
// レストランの検索条件として、キーワードに加えてジャンルと予算の絞り込みをサポートします。
// 親クラスである RestaurantSearchViewModel の機能（位置情報、半径での検索など）を継承しています。
// @Observable マクロにより、プロパティの変更が SwiftUI View に自動的に通知されます。

@Observable
class KeywordSearchViewModel: RestaurantSearchViewModel {
    // 選択されたジャンルを保持する変数。初期値は「すべて」。
    var selectedGenre: String = "すべて"
    // 選択された予算を保持する変数。初期値は「指定なし」。
    var selectedBudget: String = "指定なし"
    // 最後に検索したキーワードを保持する変数。nil の場合はキーワード検索が行われていないことを示します。
    var lastSearchedKeyword: String? = nil

    // MARK: - 検索条件の選択肢
    // 選択可能なジャンルのリスト。
    let genreOptions = ["すべて", "居酒屋", "ダイニングバー・バル", "創作料理", "和食", "洋食", "イタリアン・フレンチ", "中華", "焼肉・ホルモン", "韓国料理", "アジア・エスニック料理", "各国料理", "カラオケ・パーティ", "バー・カクテル", "ラーメン", "お好み焼き・もんじゃ", "カフェ・スイーツ", "その他グルメ"]

    // 選択可能な予算のリスト。
    let budgetOptions = ["指定なし", "〜500円", "501〜1000円", "1001〜1500円", "1501〜2000円", "2001〜3000円", "3001〜4000円", "4001〜5000円", "5001〜7000円", "7001〜10000円", "10001〜15000円", "15001〜20000円", "20001〜30000円", "30001円〜"]

    // MARK: - レストラン検索処理
    // メインスレッドで非同期にレストラン検索を実行する関数。
    // keyword が nil の場合は、現在の検索条件（ジャンル、予算）と半径に基づいて検索を行います。
    // keyword が指定された場合は、そのキーワードも検索条件に追加します。
    @MainActor
    func searchRestaurants(keyword: String? = nil) async {
        // 検索開始時にローディング状態を true に設定し、エラーを nil にリセットします。
        self.isLoading = true
        self.error = nil

        // 現在地の緯度経度を取得します。getCoordinates() は親クラス (RestaurantSearchViewModel) で定義されていると想定されます。
        let (lat, lng) = getCoordinates()

        // API リクエストに追加するパラメータを格納する辞書。
        var additionalParams: [String: String] = [:]

        // キーワードが指定されており、空でない場合に、API パラメータに追加し、最後に検索したキーワードを更新します。
        if let keyword = keyword, !keyword.isEmpty {
            additionalParams["keyword"] = keyword
            self.lastSearchedKeyword = keyword
        }

        // MARK: - API 呼び出しと結果処理
        do {
            // apiService を使用してレストラン検索 API を呼び出し、結果を取得します。
            // apiService は親クラス (RestaurantSearchViewModel) で定義され、依存性注入されていると想定されます。
            let results = try await apiService.searchRestaurants(
                lat: lat,
                lng: lng,
                radius: radius,
                additionalParams: additionalParams
            )

            // 検索結果を restaurants プロパティに格納し、ローディング状態を false に設定、検索実行フラグを true にします。
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

    // MARK: - API パラメータ変換メソッド
    // 選択されたジャンルを API が認識する形式のパラメータに変換するメソッド。
    private func convertGenreToAPIParameter(_ genre: String) -> String {
        switch genre {
        case "居酒屋": return "G001"
        case "ダイニングバー・バル": return "G002"
        case "創作料理": return "G003"
        case "和食": return "G004"
        case "洋食": return "G005"
        case "イタリアン・フレンチ": return "G006"
        case "中華": return "G007"
        case "焼肉・ホルモン": return "G008"
        case "韓国料理": return "G017"
        case "アジア・エスニック料理": return "G009"
        case "各国料理": return "G010"
        case "カラオケ・パーティ": return "G011"
        case "バー・カクテル": return "G012"
        case "ラーメン": return "G013"
        case "お好み焼き・もんじゃ": return "G016"
        case "カフェ・スイーツ": return "G014"
        case "その他グルメ": return "G015"
        case "すべて": return "" // 「すべて」の場合はパラメータを送信しない
        default: return "" // 想定外のジャンルの場合は空文字列を返す
        }
    }

    // 選択された予算を API が認識する形式のパラメータに変換するメソッド。
    private func convertBudgetToAPIParameter(_ budget: String) -> String {
        switch budget {
        case "〜500円": return "B009"
        case "501〜1000円": return "B010"
        case "1001〜1500円": return "B011"
        case "1501〜2000円": return "B001"
        case "2001〜3000円": return "B002"
        case "3001〜4000円": return "B003"
        case "4001〜5000円": return "B008"
        case "5001〜7000円": return "B004"
        case "7001〜10000円": return "B005"
        case "10001〜15000円": return "B006"
        case "15001〜20000円": return "B012"
        case "20001〜30000円": return "B013"
        case "30001円〜": return "B014"
        case "指定なし": return "" // 「指定なし」の場合はパラメータを送信しない
        default: return "" // 想定外の予算の場合は空文字列を返す
        }
    }
}
