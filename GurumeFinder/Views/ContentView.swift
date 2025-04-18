//
//  ContentView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/06.
//

import SwiftUI

struct ContentView: View {
    @State var nearbyViewModel = NearbyRestaurantsViewModel()
    @State var searchViewModel = KeywordSearchViewModel()
    @State private var inputText = ""
    @State private var selectedRestaurant: Restaurant? = nil
    @State private var showSearchResults = false
    @State private var searchKeywordForNavigation: String?

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
                    count: nearbyViewModel.restaurants.count,
                    isLoading: nearbyViewModel.isLoading,
                    currentRadius: nearbyViewModel.radius,
                    radiusOptions: nearbyViewModel.radiusOptions,
                    onRadiusChange: { newRadius in
                        nearbyViewModel.radius = newRadius
                    }
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(Color(.systemBackground))


                Divider()

                VStack(alignment: .leading, spacing: 16) {
                    Text("近くのお店")
                        .font(.title2)
                        .fontWeight(.semibold)

                    RestaurantListView(
                        viewModel: nearbyViewModel,
                        selectedRestaurant: $selectedRestaurant,
                        loadingMessage: "近くのお店を検索中...",
                        emptyMessage: "位置情報を取得して検索を開始します...",
                    )
                    .refreshable {
                        await nearbyViewModel.fetchNearbyRestaurants()
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))

                Spacer()
            }
            .background(Color(.secondarySystemBackground))
            .task {
                nearbyViewModel.requestLocationPermission()
            }
            .onChange(of: nearbyViewModel.radius) { oldRadius, newRadius in
                if oldRadius != newRadius {
                    Task {
                        await nearbyViewModel.fetchNearbyRestaurants()
                    }
                }
            }
            .onChange(of: nearbyViewModel.locationManager.location) { oldValue, newValue in
                if let _ = newValue, !nearbyViewModel.didPerformSearch {
                    Task {
                        await nearbyViewModel.fetchNearbyRestaurants()
                    }
                }
            }
            // 検索結果画面への遷移
            .navigationDestination(isPresented: $showSearchResults) {
                if let keyword = searchKeywordForNavigation {
                    SearchResultsView(viewModel: searchViewModel, searchKeyword: keyword)
                }
            }
            // 詳細画面への遷移
            .navigationDestination(item: $selectedRestaurant) { restaurant in
                RestaurantDetailView(restaurant: restaurant)
            }
        }
    }
}

    #Preview {
        ContentView()
    }
