//
//  ContentViewModel.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/07.
//

import SwiftUI

@Observable class ContentViewModel {
    let locationManager = LocationManager()
    private let apiService = APIService()

    var searchResults: [Restaurant] = []
    var isLoading = false
    var error: Error?
    var radius: Int = 3
    var selectedGenre: String = "すべて"
    var selectedBudget: String = "指定なし"
    var errorMessage: String = ""

    // オプション定義
    let radiusOptions: [Int: String] = [
        1: "300m",
        2: "500m",
        3: "1km",
        4: "2km",
        5: "3km"
    ]

    let genreOptions = ["すべて", "居酒屋", "ダイニングバー・バル", "創作料理", "和食", "洋食", "イタリアン・フレンチ", "中華", "焼肉・ホルモン", "韓国料理", "アジア・エスニック料理", "各国料理", "カラオケ・パーティ", "バー・カクテル", "ラーメン", "お好み焼き・もんじゃ", "カフェ・スイーツ", "その他グルメ"]

    let budgetOptions = ["指定なし", "〜500円", "501〜1000円", "1001〜1500円", "1501〜2000円", "2001〜3000円", "3001〜4000円", "4001〜5000円", "5001〜7000円", "7001〜10000円", "10001〜15000円", "15001〜20000円", "20001〜30000円", "30001円〜"]

    func searchRestaurants() async {
//         guard let location = locationManager.location else { return }

        isLoading = true

        // ダミーデータを使用
        let lat = 35.6608183454
        let lng = 139.7754267645

        // 実際の位置情報を使用する場合
//         let lat = location.coordinate.latitude
//         let lng = location.coordinate.longitude

        var additionalParams: [String: String] = [:]

        if selectedGenre != "すべて" && !selectedGenre.isEmpty {
            additionalParams["genre"] = convertGenreToAPIParameter(selectedGenre)
        }

        if selectedBudget != "指定なし" && !selectedBudget.isEmpty {
            additionalParams["budget"] = convertBudgetToAPIParameter(selectedBudget)
        }

        do {
            let results = try await apiService.searchRestaurants(
                lat: lat,
                lng: lng,
                radius: radius,
                additionalParams: additionalParams
            )

            await MainActor.run {
                self.searchResults = results
                self.isLoading = false
            }
        } catch {
            await MainActor.run {
                self.error = error
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
        }
    }

    // ジャンルをAPIパラメータに変換
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
        case "すべて": return ""
        default: return ""
        }
    }

    // 予算をAPIパラメータに変換
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
        case "指定なし": return ""
        default: return ""
        }
    }

    func requestLocationPermission() {
        locationManager.requestPermission()
    }

}
