//
//  RestaurantCard.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/17.
//

import SwiftUI
import Kingfisher

// レストランカードコンポーネント
struct RestaurantCard: View {
    let restaurant: Restaurant

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // レストラン画像
            RestaurantImageView(imageUrl: restaurant.photo.mobile.l)

            // レストラン情報
            VStack(alignment: .leading) {
                Text(restaurant.name)
                    .font(.headline)
                    .padding(.bottom, 2)

                RestaurantInfoRow(icon: "fork.knife", text: restaurant.genre.name)
                RestaurantInfoRow(icon: "mappin.and.ellipse", text: restaurant.access)
                RestaurantInfoRow(icon: "yensign.circle", text: restaurant.budget.average)
            }
            .padding(12)
        }
        .background(Color(.tertiarySystemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// レストラン情報の行コンポーネント
struct RestaurantInfoRow: View {
    let icon: String
    let text: String

    var body: some View {
        if !text.isEmpty {
            Label(text, systemImage: icon)
                .font(.subheadline)
                .padding(.bottom, 2)
        } else {
            EmptyView()
        }
    }
}

// レストラン画像コンポーネント
struct RestaurantImageView: View {
    let imageUrl: String?

    var body: some View {
        if let imageUrl = imageUrl, let url = URL(string: imageUrl) {
            KFImage(url)
                .placeholder { progress in
                    ImagePlaceholder(overlay: AnyView(ProgressView(value: Float(progress.fractionCompleted))))
                }
                .fade(duration: 0.3)
                .resizable()
                .scaledToFill()
                .frame(height: 140)
                .clipped()
        } else {
            ImagePlaceholder(text: "画像なし")
        }
    }
}

// プレースホルダー画像コンポーネント
struct ImagePlaceholder: View {
    var text: String? = nil
    var overlay: AnyView? = nil

    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .frame(height: 120)
            .overlay {
                if let text = text {
                    Text(text)
                } else if let overlay = overlay {
                    overlay
                }
            }
    }
}

// キャッシュ削除を行うための拡張
extension RestaurantImageView {
    static func clearCache(for imageUrl: String) {
        guard let url = URL(string: imageUrl) else { return }
        // Kingfisherのキャッシュを削除
        if ImageCache.default.isCached(forKey: url.cacheKey) {
            ImageCache.default.removeImage(forKey: url.cacheKey)
        }
    }
}

// プレビュー用のコード
#Preview {
    ContentView()
}
