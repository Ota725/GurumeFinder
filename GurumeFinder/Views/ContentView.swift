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
    @State private var showDetailSearch = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBarView(
                    inputText: $inputText,
                    onDetailSearchTap: {
                        showDetailSearch = true
                    }
                )

                Divider()
                    .padding(.bottom, 8)

                // 検索結果と検索範囲の表示エリア
                SearchResultsHeaderView(viewModel: viewModel)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 16)
                    .background(Color(.systemBackground))

                Divider()

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
            }
            .onChange(of: viewModel.locationManager.location) { oldValue, newValue in
                // 新しい位置情報がnilでなく、まだ初回検索を行っていない場合
                // Note: newValueを直接比較 (Equatable準拠のため)
                if let newLoc = newValue, !viewModel.didPerformInitialSearch {
                    print("ContentView .onChange(location): 初めて位置情報を取得しました (\(newLoc.coordinate)). 検索を開始します。")
                    Task {
                        // searchRestaurantsはMainActorで実行される
                        await viewModel.searchRestaurants()
                        // フラグ更新もMainActor上で行う
                        viewModel.didPerformInitialSearch = true
                    }
                } else if newValue != nil && oldValue == nil {
                    print("ContentView .onChange(location): 位置情報が再び利用可能になりました（初回検索は完了済み）。")
                } else if newValue == nil && oldValue != nil {
                    print("ContentView .onChange(location): 位置情報が利用不可能になりました。")
                    // 必要に応じてエラー表示や状態リセットを行う
                }
            }
            .onChange(of: viewModel.radius) { _, newRadius in
                print("検索範囲が変更されました: \(viewModel.radiusOptions[newRadius] ?? ""). 再検索を開始します。")
                Task {
                    await viewModel.searchRestaurants()
                }
            }
            .background(Color(.secondarySystemBackground))
            .navigationDestination(item: $selectedRestaurant) { restaurant in
                RestaurantDetailView(restaurant: restaurant)
            }
        }
    }
}

// 検索結果ヘッダーコンポーネント（件数と検索範囲を横並びで表示）
struct SearchResultsHeaderView: View {
    @Bindable var viewModel: ContentViewModel
    @State private var isPickerShown = false

    var body: some View {
        HStack(alignment: .center) {
            // 検索結果件数
            if viewModel.isLoading {
                Text("検索中...")
                    .font(.headline)
            } else {
                Text("\(viewModel.searchResults.count)件")
                    .font(.headline)
            }

            Spacer()

            // 右側：検索範囲
            Button {
                isPickerShown = true
            } label: {
                HStack(alignment: .center, spacing: 4) {
                    Text("検索範囲")
                        .font(.subheadline)
                        .foregroundColor(.primary)

                    Text(viewModel.radiusOptions[viewModel.radius] ?? "1km")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Image(systemName: "chevron.down")
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(.leading, 2)
                }
            }
            .buttonStyle(.plain)
        }
        .sheet(isPresented: $isPickerShown) {
            NavigationStack {
                List {
                    ForEach(viewModel.radiusOptions.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        Button {
                            viewModel.radius = key
                            isPickerShown = false
                        } label: {
                            HStack {
                                Text(value)
                                    .foregroundColor(.primary)

                                Spacer()

                                if viewModel.radius == key {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("検索範囲を選択")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button("閉じる") {
                            isPickerShown = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}

// レストラン一覧表示コンポーネント
struct RestaurantListView: View {
    var viewModel: ContentViewModel
    @Binding var selectedRestaurant: Restaurant?

    var body: some View {
        ScrollView {
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
            await viewModel.searchRestaurants()
        }
    }
}

// 検索バーコンポーネント
struct SearchBarView: View {
    @Binding var inputText: String
    var onDetailSearchTap: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 4) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(.systemGray2))
                TextField("エリア ジャンル お店など", text: $inputText)
                    .submitLabel(.search) // 改行ボタンを「検索」に変更

                if !inputText.isEmpty {
                    Button {
                        inputText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color(.systemGray2))
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .clipShape(Capsule())
            .padding(.horizontal)

            NavigationLink(destination: DetailSearchView()) {
                VStack(alignment: .center, spacing: 0) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 20))
                    Text("詳細検索")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(.primary)
        }
        .padding(12)
        .background(Color(.systemBackground))
    }
}

// 以下、既存のコードは省略

// レストラン表示グリッド
struct RestaurantGridView: View {
    let restaurants: [Restaurant]
    @Binding var selectedRestaurant: Restaurant?

    var body: some View {
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
        if !text.isEmpty {
            Label(text, systemImage: icon)
                .font(.subheadline)
                .padding(.bottom, 2)
        } else {
            EmptyView()
        }
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
