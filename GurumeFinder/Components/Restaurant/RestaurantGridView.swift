//
//  RestaurantGridView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/17.
//

import SwiftUI

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

#Preview {
    ContentView()
}
