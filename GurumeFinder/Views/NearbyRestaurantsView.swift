//
//  NearbyRestaurantsView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/18.
//

import SwiftUI

struct NearbyRestaurantsView: View {
    @Bindable var viewModel: ContentViewModel
    @Binding var selectedRestaurant: Restaurant?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.isLoadingNearby {
                    ProgressView("近くのお店を検索中...")
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let error = viewModel.nearbyError {
                    ErrorView(errorMessage: error.localizedDescription)
                } else if !viewModel.nearbyRestaurants.isEmpty {
                    RestaurantGridView(
                        restaurants: viewModel.nearbyRestaurants,
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
            print("近くのお店をリフレッシュします")
            // データの再読み込み処理を実行
            Task {
                await viewModel.fetchNearbyRestaurants()
            }
        }
    }
}

#Preview {
    ContentView()
}
