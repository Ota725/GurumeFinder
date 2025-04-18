//
//  SearchBarView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/17.
//

import SwiftUI

// 検索バーコンポーネント
struct SearchBarView: View {
    @Binding var inputText: String
    var onSearch: () -> Void
    var onDetailSearchTap: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            HStack(alignment: .center, spacing: 4) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(Color(.systemGray2))
                TextField("エリア ジャンル お店など", text: $inputText)
                    .submitLabel(.search) // 改行ボタンを「検索」に変更
                    .onSubmit {
                        onSearch() // 検索実行
                    }

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

#Preview {
    ContentView()
}
