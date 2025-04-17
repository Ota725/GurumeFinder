//
//  SwiftUIView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/06.
//

import SwiftUI

struct ResultsView: View {
    let restaurants: [Restaurant]
    @State private var currentPage = 0
    let itemsPerPage = 10

    var body: some View {
        VStack {
            if restaurants.isEmpty {
                Text("検索結果がありません")
                    .padding()
            } else {
                List {
                    ForEach(paginatedRestaurants) { restaurant in
                        NavigationLink(destination: RestaurantDetailView(restaurant: restaurant)) {
                            RestaurantRowView(restaurant: restaurant)
                        }
                    }
                }

                // ページング用のコントロール
                if restaurants.count > itemsPerPage {
                    HStack {
                        Button(action: previousPage) {
                            Image(systemName: "chevron.left")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .disabled(currentPage == 0)

                        Text("\(currentPage + 1) / \(numberOfPages)")
                            .padding(.horizontal)

                        Button(action: nextPage) {
                            Image(systemName: "chevron.right")
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.blue)
                                .cornerRadius(8)
                        }
                        .disabled(currentPage == numberOfPages - 1)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("検索結果：\(restaurants.count)件")
    }

    private var paginatedRestaurants: [Restaurant] {
        let startIndex = currentPage * itemsPerPage
        let endIndex = min(startIndex + itemsPerPage, restaurants.count)

        guard startIndex < restaurants.count else { return [] }

        return Array(restaurants[startIndex..<endIndex])
    }

    private var numberOfPages: Int {
        (restaurants.count + itemsPerPage - 1) / itemsPerPage
    }

    private func nextPage() {
        if currentPage < numberOfPages - 1 {
            currentPage += 1
        }
    }

    private func previousPage() {
        if currentPage > 0 {
            currentPage -= 1
        }
    }
}

struct RestaurantRowView: View {
    let restaurant: Restaurant

    var body: some View {
        HStack {
            // サムネイル画像
            if let imageUrl = restaurant.photo.mobile.s, let _ = URL(string: imageUrl) {
                AsyncImage(url: URL(string: imageUrl)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Rectangle()
                        .foregroundColor(.gray)
                }
                .frame(width: 80, height: 80)
                .cornerRadius(10)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120)
                    .overlay(Text("画像なし"))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(restaurant.name)
                    .font(.headline)
                    .lineLimit(1)

                Text(restaurant.genre.name)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(restaurant.access)
                    .font(.caption)
                    .foregroundColor(.gray)
                    .lineLimit(2)
            }
            .padding(.leading, 4)
        }
        .padding(.vertical, 4)
    }
}
