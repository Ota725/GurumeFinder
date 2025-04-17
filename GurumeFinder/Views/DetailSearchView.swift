//
//  DetailSearchView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/13.
//

import SwiftUI

// MARK: - 詳細検索画面
struct DetailSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedArea: MiddleArea?
    @State private var selectedGenre: String = ""
    @State private var selectedBudget: String = ""
    @State private var hasPrivateRoom: Bool = false
    @State private var servesAlcohol: Bool = false
    @State private var canBringFood: Bool = false
    @State private var showAreaSelection = false

    private let accentColor = Color.red

    // サンプルデータ（実際のアプリでは外部から注入またはAPIから取得）
    private let sampleArea = MiddleArea(
        code: "Y001",
        name: "札幌駅エリア",
        largeArea: LargeAreaReference(code: "Z001", name: "北海道"),
        serviceArea: ServiceAreaReference(code: "SA001", name: "札幌"),
        largeServiceArea: LargeServiceAreaReference(code: "LSA001", name: "北海道")
    )

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // エリア・ジャンル
                VStack(alignment: .leading, spacing: 12) {
                    Text("エリア・ジャンル")
                        .font(.headline)

                    // エリア選択
                    Button {
                        showAreaSelection = true
                    } label: {
                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                            Text(selectedArea?.name ?? "エリアを選択する")
                            Spacer()
                            if let _ = selectedArea {
                                Image(systemName: "xmark.circle.fill")
                                    .onTapGesture {
                                        selectedArea = nil  // 選択されたエリアをクリア
                                    }

                                    .foregroundColor(.gray)
                            } else {
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                        }
                        .font(.subheadline)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .foregroundColor(.primary)

                    // ジャンル選択
                    Button {
                        // ジャンル選択画面への遷移処理
                    } label: {
                        HStack {
                            Text("ジャンルを選択する")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray)
                        }
                        .font(.subheadline)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .foregroundColor(.primary)
                }
                .padding(.horizontal)

                // 予算
                VStack(alignment: .leading, spacing: 12) {
                    Text("予算")
                        .font(.headline)

                    Button {
                        // 予算選択画面への遷移処理
                    } label: {
                        HStack {
                            Text("XXXX円〜XXXX円")
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.gray)
                        }
                        .font(.subheadline)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                    }
                    .foregroundColor(.primary)
                }
                .padding(.horizontal)

                // こだわり
                VStack(alignment: .leading, spacing: 12) {
                    Text("こだわり")
                        .font(.headline)

                    VStack(alignment: .leading, spacing: 10) {
                        HStack(spacing: 10) {
                            Button(action: { hasPrivateRoom.toggle() }) {
                                Text("個室あり")
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(hasPrivateRoom ? accentColor.opacity(0.1) : Color(.systemGray6))
                                    .foregroundColor(hasPrivateRoom ? accentColor : .primary)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(hasPrivateRoom ? accentColor : Color.clear, lineWidth: 1)
                                    )
                            }

                            Button(action: { servesAlcohol.toggle() }) {
                                Text("酒類あり")
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(servesAlcohol ? accentColor.opacity(0.1) : Color(.systemGray6))
                                    .foregroundColor(servesAlcohol ? accentColor : .primary)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(servesAlcohol ? accentColor : Color.clear, lineWidth: 1)
                                    )
                            }

                            Button(action: { canBringFood.toggle() }) {
                                Text("持ち込みあり")
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 12)
                                    .background(canBringFood ? accentColor.opacity(0.1) : Color(.systemGray6))
                                    .foregroundColor(canBringFood ? accentColor : .primary)
                                    .cornerRadius(20)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(canBringFood ? accentColor : Color.clear, lineWidth: 1)
                                    )
                            }

                            Spacer()
                        }
                    }
                }
                .padding(.horizontal)

                // 選択されているエリアタグ（選択されている場合のみ表示）
                if let selectedArea = selectedArea {
                    HStack {
                        HStack {
                            Text(selectedArea.name)
                                .font(.subheadline)
                            Button {
                                self.selectedArea = nil
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.caption)
                                    .foregroundColor(.primary)
                            }
                        }
                        .padding(.vertical, 6)
                        .padding(.horizontal, 12)
                        .background(Color(.systemGray6))
                        .cornerRadius(15)

                        Spacer()
                    }
                    .padding(.horizontal)
                }

                Spacer(minLength: 100)

                // 下部ボタン
                HStack {
                    Button(action: {
                        // 選択をクリア
                        selectedArea = nil
                        selectedGenre = ""
                        selectedBudget = ""
                        hasPrivateRoom = false
                        servesAlcohol = false
                        canBringFood = false
                    }) {
                        Text("クリア")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .foregroundColor(.primary)
                            .cornerRadius(8)
                    }

                    Button(action: {
                        // 検索実行処理
                        dismiss()
                    }) {
                        Text("693件から探す")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .navigationTitle("詳細条件")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color(.systemBackground))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Text("検索履歴")
                        .foregroundColor(accentColor)
                }
            }
        }
        .onAppear {
            // 初期データをセット（テスト用）
            if selectedArea == nil {
                selectedArea = sampleArea
            }
        }
        .sheet(isPresented: $showAreaSelection) {
            NavigationStack {
                AreaSelectionView(selectedArea: $selectedArea)
            }
        }
    }
}

#Preview {
    NavigationStack {
        DetailSearchView()
    }
}
