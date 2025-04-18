//
//  SearchResultsView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/17.
//

import SwiftUI

// MARK: - SearchResultsView 概要
// キーワード検索の結果を表示する画面です。
// 初期検索キーワードに基づいてレストランを検索し、結果をリスト表示します。
// 検索キーワードの変更や、検索範囲の変更にも対応しています。
// レストランを選択すると、詳細画面へ遷移します。

struct SearchResultsView: View {
    // @Bindable プロパティラッパーを使用して、ViewModel の変更を監視し、View を更新します。
    @Bindable var viewModel: KeywordSearchViewModel
    // 画面が最初に表示される際の検索キーワードを保持します。
    let initialSearchKeyword: String
    // 検索バーに入力されたテキストを保持する状態変数。
    @State private var inputText: String = ""
    // 選択されたレストランの情報を保持し、詳細画面への遷移を制御する状態変数。
    @State private var selectedRestaurant: Restaurant?

    // イニシャライザ。ViewModel と初期検索キーワードを受け取ります。
    init(viewModel: KeywordSearchViewModel, searchKeyword: String) {
        // Bindable ラッパーを使用して ViewModel を初期化します。
        _viewModel = Bindable(viewModel)
        // 初期検索キーワードをプロパティに設定します。
        self.initialSearchKeyword = searchKeyword
        // 検索バーの初期表示テキストを設定します。
        _inputText = State(initialValue: searchKeyword)
    }

    var body: some View {
        VStack(spacing: 0) {
            // MARK: - 検索バー
            // 検索キーワードの入力と検索実行を行うための View。
            SearchBarView(
                // 検索バーのテキストフィールドと双方向バインディング。
                inputText: $inputText,
                // 検索ボタンがタップされた際の処理。
                onSearch: {
                    // 検索キーワードが空でない場合のみ検索を実行します。
                    if !inputText.isEmpty {
                        // 非同期処理としてレストラン検索を実行します。
                        Task {
                            await viewModel.searchRestaurants(keyword: inputText)
                        }
                    }
                },
                // 詳細検索ボタンがタップされた際の処理 (現状は空のクロージャ)。
                onDetailSearchTap: {}
            )

            // 検索バーと検索結果リストの間に表示する区切り線。
            Divider()
                .padding(.bottom, 8)

            // MARK: - 検索結果ヘッダー
            // 検索結果の件数や、検索範囲の表示、変更を行うための View。
            SearchResultsHeaderView(
                // 検索結果の総件数。ViewModel から取得。
                count: viewModel.restaurants.count,
                // ローディング状態を示すフラグ。ViewModel から取得。
                isLoading: viewModel.isLoading,
                // 現在の検索範囲 (半径)。ViewModel から取得。
                currentRadius: viewModel.radius,
                // 検索範囲の選択肢の配列。ViewModel から取得。
                radiusOptions: viewModel.radiusOptions,
                // 検索範囲が変更された際の処理。
                onRadiusChange: { newRadius in
                    // ViewModel の検索範囲を更新します。
                    viewModel.radius = newRadius
                }
            )
            .padding(.horizontal, 16)
            .padding(.vertical, 16)

            // 検索結果ヘッダーと検索結果リストの間に表示する区切り線。
            Divider()

            // MARK: - 検索結果表示
            // 検索されたレストランのリストを表示する View。
            RestaurantListView(
                // レストランデータの配列やローディング状態などを保持する ViewModel。
                viewModel: viewModel,
                // 選択されたレストラン。詳細画面への遷移を制御。
                selectedRestaurant: $selectedRestaurant,
                // ローディング中に表示するメッセージ。
                loadingMessage: "お店情報を検索中...",
                // 検索結果が空の場合に表示するメッセージ。
                emptyMessage: "キーワードで検索してください...",
                // 各レストランの表示方法や選択時の処理などは RestaurantListView 内部で定義。
            )
            .padding(.top, 12)
            .padding(.horizontal, 16)

            // 画面下部の余白を調整するための Spacer。
            Spacer()
        }
        // View がタスクとして最初に表示される際に実行する処理。
        .task {
            // 初期検索キーワードでレストランを検索します。
            await viewModel.searchRestaurants(keyword: initialSearchKeyword)
            // 検索が実行されたことをViewModelに記録します。
            viewModel.didPerformSearch = true
        }
        // viewModel.radius の値が変更された際に実行される処理。
        .onChange(of: viewModel.radius) { oldRadius, newRadius in
            // 古い半径と新しい半径が異なり、かつ検索キーワードが空でない場合に再検索を実行します。
            if oldRadius != newRadius && !inputText.isEmpty {
                Task {
                    await viewModel.searchRestaurants(keyword: inputText)
                }
            }
        }
        // selectedRestaurant の値が変更された際に、指定された RestaurantDetailView へ遷移します。
        .navigationDestination(item: $selectedRestaurant) { restaurant in
            RestaurantDetailView(restaurant: restaurant)
        }
    }
}

// MARK: - Preview
// この View のプレビューを表示するためのコード。
#Preview {
    // ContentView を表示することで、SearchResultsView がどのように表示されるかを確認できます。
    ContentView()
}
