//
//  PrefectureSelectionView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/14.
//

import SwiftUI

// MARK: - 都道府県選択画面
struct PrefectureSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedArea: MiddleArea?
    let areaGroups: [LargeArea]

    // 日本の地域と都道府県
    private let regions = RegionData.japanRegions

    var body: some View {
        NavigationView {
            List {
                ForEach(regions.keys.sorted(), id: \.self) { region in
                    Section(header: Text(region)) {
                        ForEach(regions[region]!, id: \.self) { prefecture in
                            Button(action: {
                                selectPrefecture(prefecture)
                            }) {
                                Text(prefecture)
                            }
                        }
                    }
                }
            }
            .navigationTitle("都道府県選択")
            .navigationBarItems(trailing: Button("閉じる") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }

    // 都道府県選択時の処理
    private func selectPrefecture(_ prefecture: String) {
        // 都道府県名から対応するエリアを探す
        // 東京都→東京、神奈川県→神奈川などのマッピング
        let prefName = prefecture.replacingOccurrences(of: "都", with: "")
            .replacingOccurrences(of: "府", with: "")
            .replacingOccurrences(of: "県", with: "")

        // 対応するLargeAreaを探す
        if let largeArea = areaGroups.first(where: { $0.name.contains(prefName) }),
           let firstMiddleArea = largeArea.middleAreas.first {
            selectedArea = firstMiddleArea
            presentationMode.wrappedValue.dismiss()
        } else {
            // マッチするエリアがない場合の処理
            print("No matching area found for prefecture: \(prefecture)")
        }
    }
}
