//
//  RestaurantResultsView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/17.
//

import SwiftUI

// RestaurantResultsView.swift - 検索結果表示用の共通コンポーネント
struct RestaurantResultsView: View {
    var viewModel: ContentViewModel
    @Binding var selectedRestaurant: Restaurant?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.isLoading {
                    ProgressView("お店情報を検索中...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let error = viewModel.error {
                    ErrorView(errorMessage: error.localizedDescription)
                } else if !viewModel.searchResults.isEmpty {
                    RestaurantGridView(
                        restaurants: viewModel.searchResults,
                        selectedRestaurant: $selectedRestaurant
                    )
                } else {
                    if viewModel.didPerformInitialSearch {
                        EmptyResultView() // 検索したが結果0件
                    } else {
                        // 初回検索前 (位置情報待ちなど)
                        Text("位置情報を取得して検索を開始します...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                    }
                }
            }
        }
        .refreshable {
            print("プルダウンリフレッシュがトリガーされました")
            // データの再読み込み処理を実行
            Task {
                await viewModel.searchRestaurants()
            }
        }
    }
}


#Preview {
    ContentView()
}
