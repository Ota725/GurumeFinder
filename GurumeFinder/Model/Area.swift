//
//  Area.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/14.
//

import Foundation

protocol IdentifiableCodeName: Identifiable, Hashable {
    var id: UUID { get }
    var code: String { get }
    var name: String { get }
}

extension IdentifiableCodeName {
    func hash(into hasher: inout Hasher) {
        hasher.combine(code)
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.code == rhs.code
    }
}

// エリアデータモデル
struct Area: IdentifiableCodeName {
    let id = UUID()
    let code: String
    let name: String
}

// サービスエリアモデル
struct ServiceArea: IdentifiableCodeName {
    let id = UUID()
    let code: String
    let name: String
}

// 大エリアモデル
struct LargeArea: IdentifiableCodeName {
    let id = UUID()
    let code: String
    let name: String
    var middleAreas: [MiddleArea] = []
}

// ミドルエリアモデル（APIレスポンスに対応）
struct MiddleArea: IdentifiableCodeName {
    let id = UUID()
    let code: String
    let name: String
    let largeArea: LargeAreaReference
    let serviceArea: ServiceAreaReference
    let largeServiceArea: LargeServiceAreaReference
}

// APIからのレスポンス参照用モデル
struct LargeAreaReference: Codable, Hashable {
    let code: String
    let name: String
}

struct ServiceAreaReference: Codable, Hashable {
    let code: String
    let name: String
}

struct LargeServiceAreaReference: Codable, Hashable {
    let code: String
    let name: String
}
