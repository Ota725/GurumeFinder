//
//  AreaResponse.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/14.
//

import Foundation

// APIレスポンス用デコーダブルモデル
struct AreaResponse: Decodable {
    let results: Results

    struct Results: Decodable {
        let api_version: String
        let results_available: Int
        let results_returned: String
        let results_start: Int
        let middle_area: [MiddleAreaResponse]
    }

    struct MiddleAreaResponse: Decodable {
        let code: String
        let name: String
        let large_area: LargeAreaReference
        let service_area: ServiceAreaReference
        let large_service_area: LargeServiceAreaReference
    }
}
