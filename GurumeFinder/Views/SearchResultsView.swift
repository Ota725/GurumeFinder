//
//  SearchResultsView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/17.
//

import SwiftUI

// 検索結果表示用の新しいビュー
struct SearchResultsView: View {
    @Bindable var viewModel : ContentViewModel
    let initialSearchKeyword: String
    // SearchBar用の入力テキスト状態変数
    @State private var inputText: String = ""
    // 次のSearchResultsViewへの遷移トリガー
    @State private var showNextSearchResults = false
    // 詳細画面遷移用
    @State private var selectedRestaurant: Restaurant?
    @State private var currentRadius: Int // 現在の検索範囲を保持
    @Environment(\.dismiss) var dismiss

    init(viewModel: ContentViewModel, searchKeyword: String) {
        _viewModel = Bindable(viewModel)
        self.initialSearchKeyword = searchKeyword
        _inputText = State(initialValue: searchKeyword)
        _currentRadius = State(initialValue: viewModel.radius)
    }

    var body: some View {
        VStack(spacing: 0) {
            // この画面専用のSearchBarView
            SearchBarView(
                inputText: $inputText,
                onSearch: {
                    if !inputText.isEmpty {
//                        nextSearchKeyword = inputText
                        Task {
                            await viewModel.searchRestaurants(keyword: inputText)
                        }
                    }
                },
                onDetailSearchTap: {}, // 詳細検索はここでは使わない想定
            )

            Divider()
                .padding(.bottom, 8)

            // 検索結果件数
            SearchResultsHeaderView(viewModel: viewModel)
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))

            Divider()

            RestaurantResultsView(
                viewModel: viewModel,
                selectedRestaurant: $selectedRestaurant
            )
            .padding(.top, 12)
            .padding(.horizontal, 16)
            .background(Color(.systemBackground))

            Spacer()
        }
        .background(Color(.secondarySystemBackground))
        .navigationTitle("")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            print("SearchResultsView: \"\(initialSearchKeyword)\" で検索を実行します。")
            await viewModel.searchRestaurants(keyword: initialSearchKeyword)
        }
        .onChange(of: viewModel.radius) { oldRadius, newRadius in
            if oldRadius != newRadius {
                print("SearchResultsHeaderView: 検索範囲が変更されました。再検索を実行します。")

                Task {
                    await viewModel.searchRestaurants(keyword: inputText)
                }
            }
        }
        .navigationDestination(item: $selectedRestaurant) { restaurant in
            RestaurantDetailView(restaurant: restaurant)
        }
        .alert("エラー", isPresented: .constant(viewModel.error != nil), presenting: viewModel.errorMessage) { message in
            Button("OK") { viewModel.error = nil; viewModel.errorMessage = "" }
        } message: { message in
            Text(message)
        }
    }
}


#Preview {
    ContentView()
}
