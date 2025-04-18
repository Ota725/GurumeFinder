//
//  RestaurantGridView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/17.
//

import SwiftUI

// レストラン表示グリッド
struct RestaurantGridView: View {
    let restaurants: [Restaurant] // 表示するレストランの配列
    @Binding var selectedRestaurant: Restaurant? // 選択されたレストラン

    var body: some View {
        LazyVStack { // 垂直方向に遅延ロード
            ForEach(restaurants) { restaurant in // 各レストランに対して
                RestaurantCard(restaurant: restaurant) // レストランカードを表示
                    .padding(.bottom, 8) // 下に余白
                    .onTapGesture { // タップ時のアクション
                        selectedRestaurant = restaurant // 選択されたレストランを更新
                    }
            }
        }
    }
}

#Preview {
    ContentView()
}
