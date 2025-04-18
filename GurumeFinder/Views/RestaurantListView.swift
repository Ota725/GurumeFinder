//
//  RestaurantListView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/18.
//

import SwiftUI

struct RestaurantListView<T: RestaurantSearchViewModel>: View {
    @Bindable var viewModel: T
    @Binding var selectedRestaurant: Restaurant?
    var loadingMessage: String
    var emptyMessage: String
//    var refreshAction: () async -> Void

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                if viewModel.isLoading {
                    ProgressView(loadingMessage)
                        .frame(maxWidth: .infinity, alignment: .center)
                } else if let error = viewModel.error {
                    ErrorView(errorMessage: error.localizedDescription)
                } else if !viewModel.restaurants.isEmpty {
                    RestaurantGridView(
                        restaurants: viewModel.restaurants,
                        selectedRestaurant: $selectedRestaurant
                    )
                } else {
                    if viewModel.didPerformSearch {
                        EmptyResultView() // 検索したが結果0件
                    } else {
                        // 初回検索前
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
