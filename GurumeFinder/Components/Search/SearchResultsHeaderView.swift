//
//  SearchResultsHeaderView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/17.
//

import SwiftUI

// 検索結果ヘッダーコンポーネント（件数と検索範囲を横並びで表示）
struct SearchResultsHeaderView: View {
    // 値渡しのプロパティ
    var count: Int
    var isLoading: Bool
    var currentRadius: Int
    var radiusOptions: [Int: String]
    var onRadiusChange: (Int) -> Void

    @State private var isPickerShown = false

    var body: some View {
        HStack(alignment: .center) {
            // 検索結果件数
            if isLoading {
                Text("検索中...")
                    .font(.headline)
            } else {
                Text("\(count)件")
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

                    Text(radiusOptions[currentRadius] ?? "1km")
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
                    ForEach(radiusOptions.sorted(by: { $0.key < $1.key }), id: \.key) { key, value in
                        Button {
                            onRadiusChange(key)
                            isPickerShown = false
                        } label: {
                            HStack {
                                Text(value)
                                    .foregroundColor(.primary)

                                Spacer()

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
                            isPickerShown = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}

#Preview {
    ContentView()
}
