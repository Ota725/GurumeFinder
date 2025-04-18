//
//  SearchResultsView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/17.
//

import SwiftUI

struct SearchResultsView: View {
    @Bindable var viewModel: KeywordSearchViewModel
    let initialSearchKeyword: String
    @State private var inputText: String = ""
    @State private var selectedRestaurant: Restaurant?

    init(viewModel: KeywordSearchViewModel, searchKeyword: String) {
        _viewModel = Bindable(viewModel)
        self.initialSearchKeyword = searchKeyword
        _inputText = State(initialValue: searchKeyword)
    }

    var body: some View {
        VStack(spacing: 0) {
            // 検索バー
            SearchBarView(
                inputText: $inputText,
                onSearch: {
                    if !inputText.isEmpty {
                        Task {
                            await viewModel.searchRestaurants(keyword: inputText)
                        }
                    }
                },
                onDetailSearchTap: {}
            )

            Divider()
                .padding(.bottom, 8)

            // 検索結果ヘッダー
            SearchResultsHeaderView(
                count: viewModel.restaurants.count,
                isLoading: viewModel.isLoading,
                currentRadius: viewModel.radius,
                radiusOptions: viewModel.radiusOptions,
                onRadiusChange: { newRadius in
                    viewModel.radius = newRadius
                }
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            Divider()

            // 検索結果表示
            RestaurantListView(
                viewModel: viewModel,
                selectedRestaurant: $selectedRestaurant,
                loadingMessage: "お店情報を検索中...",
                emptyMessage: "キーワードで検索してください...",
            )
            .padding(.top, 12)
            .padding(.horizontal, 16)

            Spacer()
        }
        .task {
            await viewModel.searchRestaurants(keyword: initialSearchKeyword)
        }
        .onChange(of: viewModel.radius) { oldRadius, newRadius in
            if oldRadius != newRadius && !inputText.isEmpty {
                Task {
                    await viewModel.searchRestaurants(keyword: inputText)
                }
            }
        }
        .navigationDestination(item: $selectedRestaurant) { restaurant in
            RestaurantDetailView(restaurant: restaurant)
        }
    }
}


#Preview {
    ContentView()
}
