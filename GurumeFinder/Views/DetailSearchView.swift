//
//  DetailSearchView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/13.
//

import SwiftUI

// MARK: - DetailSearchView 概要
// 詳細なレストラン検索条件（エリア、ジャンル、予算、こだわり）を設定するための画面です。
// ユーザーが選択した条件は @State 変数で保持されます。
// UIは ScrollView 内に VStack で各条件セクション (genre, budget, preferences) を配置し、
// 下部にクリアボタンと検索実行ボタン (actionButtons) を表示します。
// 検索実行後は dismiss() で画面を閉じます (検索処理自体は呼び出し元で行う想定)。
// 各セクションやヘルパーメソッドは MARK コメントで整理されています。

struct DetailSearchView: View {
    // この View を閉じるための Environment 変数
    @Environment(\.dismiss) private var dismiss
    // 選択された検索条件を保持する状態変数
    @State private var selectedGenre: String = "" // TODO: ジャンル選択ロジック実装
    @State private var selectedBudget: String = "" // TODO: 予算選択ロジック実装
    @State private var hasPrivateRoom: Bool = false
    @State private var servesAlcohol: Bool = false
    @State private var canBringFood: Bool = false
    @State private var showAreaSelection = false // TODO: エリア選択画面表示フラグ (遷移先未実装)

    // アプリケーションのアクセントカラー (赤)
    private let accentColor = Color.red

    var body: some View {
        // 条件が多くなる可能性を考慮し ScrollView を使用
        ScrollView {
            VStack(spacing: 20) {
                genreSection
                budgetSection
                preferencesSection
                // ボタンが最下部に固定されないように、可変長のスペーサーを配置
                Spacer(minLength: 100)
                actionButtons
            }
            .padding(.vertical) // 上下に余白を追加
        }
        .navigationTitle("詳細条件")
        .navigationBarTitleDisplayMode(.inline) // タイトルを小さく表示
        .background(Color(.systemBackground)) // システム標準の背景色
    }

    // MARK: - ジャンルセクション
    private var genreSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("エリア・ジャンル").font(.headline)

            // エリア選択ボタン (タップでエリア選択画面へ遷移する想定)
            Button {
                // TODO: エリア選択画面への遷移処理を実装する
                showAreaSelection = true // 現状はフラグを立てるのみ
            } label: {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text("エリアを選択する") // TODO: 選択されたエリア名を表示するように変更
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.gray)
                }
                .font(.subheadline)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .foregroundColor(.primary)

            // ジャンル選択ボタン (タップでジャンル選択画面へ遷移する想定)
            Button {
                // TODO: ジャンル選択画面への遷移処理を実装する
            } label: {
                HStack {
                    Text("ジャンルを選択する") // TODO: 選択されたジャンル名を表示するように変更
                    Spacer()
                    Image(systemName: "chevron.right").foregroundColor(.gray)
                }
                .font(.subheadline)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .foregroundColor(.primary)
        }
        .padding(.horizontal)
    }

    // MARK: - 予算セクション
    private var budgetSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("予算").font(.headline)

            // 予算選択ボタン (タップで予算選択UIを表示する想定)
            Button {
                // TODO: 予算選択画面 (または Picker など) への遷移/表示処理を実装する
            } label: {
                HStack {
                    Text("XXXX円〜XXXX円") // TODO: 選択された予算を表示するように変更 (selectedBudget を使用)
                    Spacer()
                    Image(systemName: "chevron.down").foregroundColor(.gray)
                }
                .font(.subheadline)
                .padding(10)
                .background(Color(.systemGray6))
                .cornerRadius(8)
            }
            .foregroundColor(.primary)
        }
        .padding(.horizontal)
    }

    // MARK: - こだわりセクション
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("こだわり").font(.headline)

            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 10) {
                    // 各こだわり条件をトグルボタンで表示・選択
                    // preferenceButton ヘルパーメソッドで UI を共通化
                    preferenceButton(title: "個室あり", isSelected: hasPrivateRoom) {
                        hasPrivateRoom.toggle()
                    }
                    preferenceButton(title: "酒類あり", isSelected: servesAlcohol) {
                        servesAlcohol.toggle()
                    }
                    preferenceButton(title: "持ち込みあり", isSelected: canBringFood) {
                        canBringFood.toggle()
                    }
                    Spacer() // 左寄せにするための Spacer
                }
            }
        }
        .padding(.horizontal)
    }

    // MARK: - アクションボタン (クリア・検索)
    private var actionButtons: some View {
        HStack {
            // クリアボタン: 選択された条件をリセット
            Button(action: clearSelections) {
                Text("クリア")
                    .frame(maxWidth: .infinity) // 幅を均等にする
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(.primary)
                    .cornerRadius(8)
            }

            // 検索ボタン: 現在の条件で検索を実行 (して画面を閉じる)
            Button(action: executeSearch) {
                Text("検索")
                    .frame(maxWidth: .infinity) // 幅を均等にする
                    .padding()
                    .background(accentColor) // 目立たせるためにアクセントカラーを使用
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(.horizontal)
    }

    // MARK: - ヘルパーメソッド (UI部品)
    // こだわり条件ボタンの共通UIを生成するメソッド
    private func preferenceButton(title: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.caption) // 少し小さめのフォント
                .padding(.vertical, 8)
                .padding(.horizontal, 12)
            // 選択状態に応じて背景色と文字色を変更
                .background(isSelected ? accentColor.opacity(0.1) : Color(.systemGray6))
                .foregroundColor(isSelected ? accentColor : .primary)
                .cornerRadius(20) // 角丸を大きくしてタグのような見た目に
            // 選択状態に応じて枠線を表示
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isSelected ? accentColor : Color.clear, lineWidth: 1)
                )
        }
    }

    // MARK: - ヘルパーメソッド (アクション)
    // 選択された全ての条件を初期状態に戻す
    private func clearSelections() {
        selectedGenre = ""
        selectedBudget = ""
        hasPrivateRoom = false
        servesAlcohol = false
        canBringFood = false
        // TODO: エリア選択の状態もクリアする必要があれば追加
    }

    // 検索を実行する (現状は画面を閉じるのみ)
    private func executeSearch() {
        // TODO: 選択された条件 (selectedGenre, selectedBudget, 各Bool値) を
        //       呼び出し元 (例えば、検索結果表示ViewModelなど) に渡し、
        //       APIリクエストなどの検索処理をトリガーする必要がある。
        //       現状は画面を閉じるだけ。
        dismiss()
    }
}

#Preview {
    NavigationStack {
        DetailSearchView()
    }
}
