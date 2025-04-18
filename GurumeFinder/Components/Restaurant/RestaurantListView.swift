//
//  RestaurantListView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/18.
//

import SwiftUI

struct RestaurantListView<T: RestaurantSearchViewModel>: View {
    @Bindable var viewModel: T // レストラン検索ViewModel
    @Binding var selectedRestaurant: Restaurant? // 選択されたレストラン
    var loadingMessage: String // ロード中メッセージ
    var emptyMessage: String // 結果なしメッセージ

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // ロード中表示
                if viewModel.isLoading {
                    ProgressView(loadingMessage)
                        .frame(maxWidth: .infinity, alignment: .center)
                }
                // エラー表示
                else if let error = viewModel.error {
                    ErrorView(errorMessage: error.localizedDescription)
                }
                // レストランリスト表示
                else if !viewModel.restaurants.isEmpty {
                    RestaurantGridView(
                        restaurants: viewModel.restaurants,
                        selectedRestaurant: $selectedRestaurant
                    )
                }
                // 結果なし表示
                else {
                    if viewModel.didPerformSearch {
                        EmptyResultView() // 検索後の結果なし
                    } else {
                        // 初回表示時のメッセージ
                        Text(emptyMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, 40)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
