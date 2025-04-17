//
//  ContentView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/06.
//

import SwiftUI

struct ContentView: View {
    @State var viewModel = ContentViewModel()
    @State private var inputText = ""
    @State private var selectedRestaurant: Restaurant? = nil
    @State private var showSearchResults = false
    @State private var searchKeywordForNavigation: String? // 遷移用のキーワード

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBarView(
                    inputText: $inputText,
                    onSearch: {
                        if !inputText.isEmpty {
                            searchKeywordForNavigation = inputText // 遷移用にキーワードを保持
                            showSearchResults = true
                            inputText = ""
                            print("SearchBarView - onSearch: 検索キーワード: \(inputText)")
                        }
                    },
                    onDetailSearchTap: {}
                )

                Divider()
                    .padding(.bottom, 8)

                // 検索結果と検索範囲の表示エリア
                SearchResultsHeaderView(
                    viewModel: viewModel,
                    count: viewModel.nearbyRestaurants.count,
                    isLoading: viewModel.isLoadingNearby
                )
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))
                

                Divider()

                VStack(alignment: .leading, spacing: 16) {
                    Text("近くのお店")
                        .font(.title2)
                        .fontWeight(.semibold)

                    NearbyRestaurantsView(
                        viewModel: viewModel,
                        selectedRestaurant: $selectedRestaurant
                    )
                }
                .padding(16)
                .background(Color(.systemBackground))

                Spacer()
            }
            .task {
                viewModel.requestLocationPermission()
            }
            .onChange(of: viewModel.radius) { oldRadius, newRadius in
                if oldRadius != newRadius {
                    print("SearchResultsHeaderView: 検索範囲が変更されました。再検索を実行します。")

                    Task {
                        await viewModel.fetchNearbyRestaurants()
                    }
                }
            }
            .onChange(of: viewModel.locationManager.location) { oldValue, newValue in
                // 新しい位置情報がnilでなく、まだ初回検索を行っていない場合
                // Note: newValueを直接比較 (Equatable準拠のため)
                if let newLoc = newValue, !viewModel.didPerformInitialSearch {
                    print("ContentView .onChange(location): 初めて位置情報を取得しました (\(newLoc.coordinate)). 検索を開始します。")
                    Task {
                        // searchRestaurantsはMainActorで実行される
                        await viewModel.fetchNearbyRestaurants()
                        // フラグ更新もMainActor上で行う
//                        viewModel.didPerformInitialSearch = true
                    }
                } else if newValue != nil && oldValue == nil {
                    print("ContentView .onChange(location): 位置情報が再び利用可能になりました（初回検索は完了済み）。")
                } else if newValue == nil && oldValue != nil {
                    print("ContentView .onChange(location): 位置情報が利用不可能になりました。")
                    // 必要に応じてエラー表示や状態リセットを行う
                }
            }
            .background(Color(.secondarySystemBackground))
            .navigationDestination(item: $selectedRestaurant) { restaurant in
                RestaurantDetailView(restaurant: restaurant)
            }
            .navigationDestination(isPresented: $showSearchResults) {
                if let keyword = searchKeywordForNavigation {
                    // 新しいViewModelインスタンスを作成して渡す
                    SearchResultsView(viewModel: viewModel, searchKeyword: keyword)
                }
            }
        }
    }
}

    #Preview {
        ContentView()
    }
