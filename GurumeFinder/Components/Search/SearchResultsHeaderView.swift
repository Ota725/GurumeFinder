//
//  SearchResultsHeaderView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/17.
//

import SwiftUI

// 検索結果ヘッダーコンポーネント（件数と検索範囲を横並びで表示）
struct SearchResultsHeaderView: View {
    var count: Int // 検索結果件数
    var isLoading: Bool // ロード中フラグ
    var currentRadius: Int // 現在の検索範囲
    var radiusOptions: [Int: String] // 検索範囲の選択肢
    var onRadiusChange: (Int) -> Void // 検索範囲変更時のアクション

    @State private var isPickerShown = false // 範囲ピッカー表示フラグ

    var body: some View {
        HStack(alignment: .center) {
            // 検索結果件数表示
            if isLoading {
                Text("検索中...")
                    .font(.headline)
            } else {
                Text("\(count)件")
                    .font(.headline)
            }

            Spacer()

            // 検索範囲選択ボタン
            Button {
                isPickerShown = true // ピッカー表示
            } label: {
                HStack(alignment: .center, spacing: 4) {
                    Text("検索範囲")
                        .font(.subheadline)
                        .foregroundColor(.primary)

                    Text(radiusOptions[currentRadius] ?? "1km") // 現在の範囲を表示
                        .font(.headline)
                        .foregroundColor(.primary)

                    Image(systemName: "chevron.down") // 下向き矢印
                        .font(.caption)
                        .foregroundColor(.primary)
                        .padding(.leading, 2)
                }
            }
            .buttonStyle(.plain) // デフォルトのボタン装飾を削除
        }
        // 検索範囲ピッカーシート
        .sheet(isPresented: $isPickerShown) {
            NavigationStack {
                List {
                    // 検索範囲の選択肢をリスト表示
                    ForEach(radiusOptions.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        Button {
                            onRadiusChange(key) // 範囲変更アクション
                            isPickerShown = false // ピッカーを閉じる
                        } label: {
                            HStack {
                                Text(value) // 範囲のテキスト
                                    .foregroundColor(.primary)
                                Spacer()
                                // 現在選択中の範囲にチェックマークを表示
                                if currentRadius == key {
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
                            isPickerShown = false // ピッカーを閉じる
                        }
                    }
                }
            }
            .presentationDetents([.medium]) // シートの高さ
        }
    }
}

#Preview {
    ContentView()
}
