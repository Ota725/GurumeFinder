//
//  SearchResultsHeaderView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/17.
//

import SwiftUI

// 検索結果ヘッダーコンポーネント（件数と検索範囲を横並びで表示）
struct SearchResultsHeaderView: View {
    @Bindable var viewModel: ContentViewModel
    @State private var isPickerShown = false
    @Environment(\.dismiss) var dismiss

    // 表示するカウントとローディング状態を引数で受け取れるようにする
    var count: Int
    var isLoading: Bool

    // 初期化時にデフォルト値を使用できるイニシャライザを追加
    init(viewModel: ContentViewModel, count: Int? = nil, isLoading: Bool? = nil) {
        self.viewModel = viewModel
        // countとisLoadingが明示的に指定されていない場合はデフォルト値（searchResults）を使用
        self.count = count ?? viewModel.searchResults.count
        self.isLoading = isLoading ?? viewModel.isLoading
    }
    
    var body: some View {
        HStack(alignment: .center) {
            // 検索結果件数
            if viewModel.isLoading {
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

#Preview {
    ContentView()
}
