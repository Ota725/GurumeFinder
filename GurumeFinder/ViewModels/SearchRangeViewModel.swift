//
//  SearchRangeViewModel.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/18.
//

import Observation

@Observable
class SearchRangeViewModel {
    var radius: Int = 3

    let radiusOptions: [Int: String] = [
        1: "300m",
        2: "500m",
        3: "1km",
        4: "2km",
        5: "3km"
    ]
}
