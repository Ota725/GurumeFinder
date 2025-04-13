//
//  ContentView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/06.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @State private var inputText = ""
    @State private var selectedRestaurant: Restaurant? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBarView(inputText: $inputText)

                Divider()
                    .padding(.bottom, 16)

                RestaurantListView(
                    viewModel: viewModel,
                    selectedRestaurant: $selectedRestaurant
                )
                .padding(16)
                .background(Color(.systemBackground))

                Spacer()
            }
            .task {
                viewModel.requestLocationPermission()
                await viewModel.searchRestaurants()
            }
            .background(Color(.secondarySystemBackground))
            .navigationDestination(item: $selectedRestaurant) { restaurant in
                RestaurantDetailView(restaurant: restaurant)
            }
        }
    }
}

// 検索バーコンポーネント
struct SearchBarView: View {
    @Binding var inputText: String

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 4) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(.systemGray2))
                TextField("エリア ジャンル お店など", text: $inputText)
            }
            .padding(8)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
            .padding(.horizontal)

            // 詳細検索ボタン
            VStack(alignment: .center, spacing: 0) {
                Image(systemName: "slider.horizontal.3")
                    .font(.system(size: 20))
                Text("詳細検索")
                    .font(.caption)
                    .fontWeight(.semibold)
            }
        }
        .padding(12)
        .background(Color(.systemBackground))
    }
}

// レストラン一覧表示コンポーネント
struct RestaurantListView: View {
    var viewModel: ContentViewModel
    @Binding var selectedRestaurant: Restaurant?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("近くのお店")
                .font(.title2)
                .fontWeight(.semibold)

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
                EmptyResultView()
            }
        }
    }
}

// レストラン表示グリッド
struct RestaurantGridView: View {
    let restaurants: [Restaurant]
    @Binding var selectedRestaurant: Restaurant?

    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(restaurants) { restaurant in
                    RestaurantCard(restaurant: restaurant)
                        .padding(.bottom, 8)
                        .onTapGesture {
                            selectedRestaurant = restaurant
                        }
                }
            }
        }
    }
}

// エラー表示コンポーネント
struct ErrorView: View {
    let errorMessage: String

    var body: some View {
        Text("エラーが発生しました: \(errorMessage)")
            .foregroundColor(.red)
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

// 検索結果なし表示コンポーネント
struct EmptyResultView: View {
    var body: some View {
        Text("検索結果はありません")
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

// レストランカードコンポーネント
struct RestaurantCard: View {
    let restaurant: Restaurant

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // レストラン画像
            RestaurantImageView(imageUrl: restaurant.photo.mobile.l)

            // レストラン情報
            VStack(alignment: .leading) {
                Text(restaurant.name)
                    .font(.headline)
                    .padding(.bottom, 2)

                RestaurantInfoRow(icon: "fork.knife", text: restaurant.genre.name)
                RestaurantInfoRow(icon: "mappin.and.ellipse", text: restaurant.access)
                RestaurantInfoRow(icon: "yensign.circle", text: restaurant.budget.average)
            }
            .padding(12)
        }
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// レストラン情報の行コンポーネント
struct RestaurantInfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        Label(text, systemImage: icon)
            .font(.subheadline)
            .padding(.bottom, 2)
    }
}

// レストラン画像コンポーネント
struct RestaurantImageView: View {
    let imageUrl: String?

    var body: some View {
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(height: 140)
                        .clipped()
                case .failure(_):
                    ImagePlaceholder(text: "画像読み込みエラー")
                case .empty:
                    ImagePlaceholder(overlay: AnyView(ProgressView()))
                @unknown default:
                    EmptyView()
                }
            }
        } else {
            ImagePlaceholder(text: "画像なし")
        }
    }
}

// プレースホルダー画像コンポーネント
struct ImagePlaceholder: View {
    var text: String? = nil
    var overlay: AnyView? = nil

    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(height: 120)
            .overlay {
                if let text = text {
                    Text(text)
                } else if let overlay = overlay {
                    overlay
                }
            }
    }
}

    #Preview {
        ContentView()
    }
