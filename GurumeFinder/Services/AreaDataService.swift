//
//  AreaDataService.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/14.
//

import Foundation

// MARK: - エリアデータサービス
struct AreaDataService {
    // サンプルデータを作成
    static func sampleAreaData() -> [MiddleArea] {
        // ここで提供されたJSONデータをパースしたミドルエリア配列を返す
        // 実際のアプリでは、JSONデコードでデータを取得

        // サンプルデータ（JSONから抽出したデータ）
        return [
            MiddleArea(
                code: "Y005",
                name: "銀座・有楽町・新橋・築地・月島",
                largeArea: LargeAreaReference(code: "Z011", name: "東京"),
                serviceArea: ServiceAreaReference(code: "SA11", name: "東京"),
                largeServiceArea: LargeServiceAreaReference(code: "SS10", name: "関東")
            ),
            MiddleArea(
                code: "Y006",
                name: "水道橋・飯田橋・神楽坂",
                largeArea: LargeAreaReference(code: "Z011", name: "東京"),
                serviceArea: ServiceAreaReference(code: "SA11", name: "東京"),
                largeServiceArea: LargeServiceAreaReference(code: "SS10", name: "関東")
            ),
            MiddleArea(
                code: "Y007",
                name: "お台場",
                largeArea: LargeAreaReference(code: "Z011", name: "東京"),
                serviceArea: ServiceAreaReference(code: "SA11", name: "東京"),
                largeServiceArea: LargeServiceAreaReference(code: "SS10", name: "関東")
            ),
            MiddleArea(
                code: "Y084",
                name: "武蔵小杉・元住吉・新丸子",
                largeArea: LargeAreaReference(code: "Z012", name: "神奈川"),
                serviceArea: ServiceAreaReference(code: "SA12", name: "神奈川"),
                largeServiceArea: LargeServiceAreaReference(code: "SS10", name: "関東")
            ),
            MiddleArea(
                code: "Y085",
                name: "新横浜・綱島・菊名・鴨居",
                largeArea: LargeAreaReference(code: "Z012", name: "神奈川"),
                serviceArea: ServiceAreaReference(code: "SA12", name: "神奈川"),
                largeServiceArea: LargeServiceAreaReference(code: "SS10", name: "関東")
            )
        ]
    }

    // ミドルエリアから地域グループを作成
    static func createAreaGroups(from middleAreas: [MiddleArea]) -> [LargeArea] {
        var groups: [String: LargeArea] = [:]

        // 大エリアごとにグループ化
        for middleArea in middleAreas {
            let largeAreaCode = middleArea.largeArea.code

            if var group = groups[largeAreaCode] {
                group.middleAreas.append(middleArea)
                groups[largeAreaCode] = group
            } else {
                var newGroup = LargeArea(
                    code: largeAreaCode,
                    name: middleArea.largeArea.name
                )
                newGroup.middleAreas.append(middleArea)
                groups[largeAreaCode] = newGroup
            }
        }

        // 配列に変換してソート
        return groups.values.sorted { $0.name < $1.name }
    }
}
