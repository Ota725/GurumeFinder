//
//  AreaSelectionView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/14.
//

import SwiftUI

// MARK: - エリア選択画面
struct AreaSelectionView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var selectedArea: MiddleArea?

    @State private var searchText = ""
    @State private var showPrefectures = false
    @State private var areaGroups: [LargeArea] = []
    @State private var isLoading = true

    // 検索結果をフィルタリング
    private var filteredAreas: [MiddleArea] {
        if searchText.isEmpty {
            return []
        }

        var results: [MiddleArea] = []
        for largeArea in areaGroups {
            for middleArea in largeArea.middleAreas {
                if middleArea.name.contains(searchText) {
                    results.append(middleArea)
                }
            }
        }

        return results
    }

    var body: some View {
        VStack(spacing: 0) {
            // 検索バー
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("エリアや駅を検索", text: $searchText)
                    .padding(8)

                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemGray6))

            if isLoading {
                // ローディング表示
                ProgressView()
                    .padding()
            } else {
                List {
                    // 都道府県から探す
                    Section {
                        Button(action: {
                            showPrefectures = true
                        }) {
                            HStack {
                                Image(systemName: "map")
                                    .foregroundColor(.blue)
                                Text("都道府県から探す")
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                    }

                    // 検索結果または地域一覧
                    if !searchText.isEmpty {
                        // 検索結果表示
                        Section(header: Text("検索結果")) {
                            ForEach(filteredAreas) { area in
                                Button(action: {
                                    selectedArea = area
                                    presentationMode.wrappedValue.dismiss()
                                }) {
                                    VStack(alignment: .leading) {
                                        Text(area.name)
                                        Text(area.largeArea.name)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                }
                            }
                        }
                    } else {
                        // 地域ごとにエリア一覧表示
                        ForEach(areaGroups) { largeArea in
                            Section(header: Text(largeArea.name)) {
                                ForEach(largeArea.middleAreas) { middleArea in
                                    Button(action: {
                                        selectedArea = middleArea
                                        presentationMode.wrappedValue.dismiss()
                                    }) {
                                        Text(middleArea.name)
                                    }
                                }
                            }
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .navigationTitle("エリア選択")
        .navigationBarItems(trailing: Button("閉じる") {
            presentationMode.wrappedValue.dismiss()
        })
        .onAppear {
            // データ読み込み
            loadAreaData()
        }
        .sheet(isPresented: $showPrefectures) {
            PrefectureSelectionView(selectedArea: $selectedArea, areaGroups: areaGroups)
        }
    }

    // エリアデータの読み込み
    private func loadAreaData() {
        // 実際のアプリではAPIからデータを取得または
        // JSONファイルから読み込む処理を実装します

        // サンプルデータの設定
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.areaGroups = AreaDataService.createAreaGroups(from: AreaDataService.sampleAreaData())
            self.isLoading = false
        }
    }
}
