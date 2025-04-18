import SwiftUI

// MARK: - ContentView 設計概要
// このViewはアプリのメイン画面であり、以下の責務を持ちます。
// 1. ユーザーの現在地周辺のレストランリスト表示 (Nearby)
// 2. キーワードによるレストラン検索機能の提供 (Keyword Search)
// 3. 上記リストや検索結果からレストラン詳細画面への遷移
//
// ViewModel:
// - NearbyRestaurantsViewModel: 位置情報取得、周辺レストランAPI呼び出し、検索範囲管理、結果リスト保持
// - KeywordSearchViewModel: キーワード検索API呼び出し、結果リスト保持
//
// 状態管理:
// - @State nearbyViewModel, searchViewModel: 各機能のViewModelインスタンス
// - @State inputText: 検索バーの入力テキスト
// - @State selectedRestaurant: 詳細画面へ遷移するための選択されたレストラン情報 (nilの場合は非表示)
// - @State showSearchResults: キーワード検索結果画面への遷移トリガー
// - @State searchKeywordForNavigation: 検索実行時に遷移先へ渡すキーワードを一時保持
//
// データフローとトリガー:
// - アプリ起動時(.task): 位置情報権限リクエスト
// - 位置情報取得後(.onChange of location): 初回の周辺レストラン検索実行
// - 検索範囲変更時(.onChange of radius): 周辺レストラン再検索
// - プルリフレッシュ(.refreshable): 周辺レストラン再検索
// - 検索バー実行(onSearch): キーワードを保持し、検索結果画面へ遷移 ($showSearchResults = true)
// - リスト項目タップ: $selectedRestaurant に値をセットし、詳細画面へ遷移
//
// その他:
// - NavigationStack: 画面遷移を実現
// - APIService: API通信ロジックを集約 (シングルトン)

struct ContentView: View {
    let apiService = APIService.shared // API通信サービス (シングルトン)
    @State var nearbyViewModel = NearbyRestaurantsViewModel() // 近くのお店用ViewModel
    @State var searchViewModel = KeywordSearchViewModel() // キーワード検索用ViewModel
    @State private var inputText = "" // 検索バー入力テキスト
    @State private var selectedRestaurant: Restaurant? = nil // 詳細表示用レストラン
    @State private var showSearchResults = false // キーワード検索結果表示フラグ
    @State private var searchKeywordForNavigation: String? // 遷移時に使う検索キーワード

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                SearchBarView(
                    inputText: $inputText,
                    onSearch: {
                        // 検索実行時の処理
                        if !inputText.isEmpty {
                            // 遷移用にキーワードを退避 (inputTextはこの後クリアされるため)
                            searchKeywordForNavigation = inputText
                            showSearchResults = true // 検索結果画面へ遷移
                            inputText = "" // 検索バーをクリア
                        }
                    },
                    onDetailSearchTap: {} // 詳細検索は未実装
                )

                Divider().padding(.bottom, 8)

                // 検索結果件数と検索範囲選択を表示するヘッダー
                SearchResultsHeaderView(
                    count: nearbyViewModel.restaurants.count,
                    isLoading: nearbyViewModel.isLoading,
                    currentRadius: nearbyViewModel.radius,
                    radiusOptions: nearbyViewModel.radiusOptions,
                    onRadiusChange: { newRadius in
                        // 半径が変更されたらViewModelのプロパティを更新
                        // .onChange(of: nearbyViewModel.radius) で再検索がトリガーされる
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

                    // 近くのお店リスト表示
                    RestaurantListView(
                        viewModel: nearbyViewModel,
                        selectedRestaurant: $selectedRestaurant, // タップで詳細画面へ遷移
                        loadingMessage: "近くのお店を検索中...",
                        emptyMessage: "位置情報を取得して検索を開始します..."
                    )
                    // プルリフレッシュで再検索
                    .refreshable {
                        await nearbyViewModel.fetchNearbyRestaurants()
                    }
                }
                .padding(16)
                .background(Color(.systemBackground))

                Spacer() // コンテンツを上部に寄せる
            }
            .background(Color(.secondarySystemBackground)) // 全体の背景色
            // View表示時に位置情報権限を要求
            .task {
                nearbyViewModel.requestLocationPermission()
            }
            // 検索半径の変更を監視して再検索
            .onChange(of: nearbyViewModel.radius) { oldRadius, newRadius in
                if oldRadius != newRadius {
                    Task { await nearbyViewModel.fetchNearbyRestaurants() }
                }
            }
            // 位置情報の初回取得/更新を監視して初回検索を実行
            .onChange(of: nearbyViewModel.locationManager.location) { oldValue, newValue in
                // 位置情報が有効で、まだ検索を実行していない場合のみ実行
                if let _ = newValue, !nearbyViewModel.didPerformSearch {
                    Task { await nearbyViewModel.fetchNearbyRestaurants() }
                }
            }
            // キーワード検索結果画面への遷移
            .navigationDestination(isPresented: $showSearchResults) {
                if let keyword = searchKeywordForNavigation {
                    SearchResultsView(viewModel: searchViewModel, searchKeyword: keyword)
                }
            }
            // レストラン詳細画面への遷移
            .navigationDestination(item: $selectedRestaurant) { restaurant in
                RestaurantDetailView(restaurant: restaurant)
            }
        }
    }
}

#Preview {
    ContentView()
}
