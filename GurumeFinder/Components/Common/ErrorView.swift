//
//  ErrorView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/17.
//

import SwiftUI

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

#Preview {
    ContentView()
}
