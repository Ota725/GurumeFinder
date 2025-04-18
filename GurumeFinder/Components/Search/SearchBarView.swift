//
//  SearchBarView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/17.
//

import SwiftUI

// 検索バーコンポーネント
struct SearchBarView: View {
    @Binding var inputText: String // 検索テキスト
    var onSearch: () -> Void // 検索実行アクション
    var onDetailSearchTap: () -> Void // 詳細検索タップアクション

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // 検索入力フィールド
            HStack(alignment: .center, spacing: 4) {
                Image(systemName: "magnifyingglass") // 虫眼鏡アイコン
                    .foregroundColor(Color(.systemGray2))
                TextField("エリア ジャンル お店など", text: $inputText) // 検索プレースホルダー
                    .submitLabel(.search) // リターンキーを「検索」に変更
                    .onSubmit {
                        onSearch() // 検索実行
                    }

                // クリアボタン (テキストが空でない場合のみ表示)
                if !inputText.isEmpty {
                    Button {
                        inputText = "" // テキストクリア
                    } label: {
                        Image(systemName: "xmark.circle.fill") // バツ印アイコン
                            .foregroundColor(Color(.systemGray2))
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6)) // 薄いグレーの背景
            .clipShape(Capsule()) // カプセル型
            .padding(.horizontal)

            // 詳細検索ボタン (NavigationLinkで遷移)
            NavigationLink(destination: DetailSearchView()) {
                VStack(alignment: .center, spacing: 0) {
                    Image(systemName: "slider.horizontal.3") // スライダーアイコン
                        .font(.system(size: 20))
                    Text("詳細検索") // 詳細検索テキスト
                        .font(.caption)
                        .fontWeight(.semibold)
                }
            }
            .foregroundColor(.primary)
        }
        .padding(12)
        .background(Color(.systemBackground)) // システム背景色
    }
}

#Preview {
    ContentView()
}
