//
//  EmptyResultView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/17.
//

import SwiftUI

// 検索結果なし表示コンポーネント
struct EmptyResultView: View {
    var body: some View {
        Text("検索結果はありません")
            .padding()
            .frame(maxWidth: .infinity, alignment: .center)
    }
}

#Preview {
    ContentView()
}
