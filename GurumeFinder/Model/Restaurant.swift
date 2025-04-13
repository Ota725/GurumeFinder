//
//  Restaurant.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/06.
//

struct RestaurantResponse: Codable {
    let results: Results

    struct Results: Codable {
        let shop: [Restaurant]
    }
}

struct Restaurant: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let address: String
    let access: String
    let lat: Double
    let lng: Double
    let logoImage: String
    let photo: Photo
    let open: String
    let close: String?
    let budget: Budget
    let genre: Genre
    let urls: URLs
    let coupon_urls: CouponURLs?
    let tel: String?

    struct Photo: Codable, Hashable {
        let mobile: Mobile

        struct Mobile: Codable, Hashable {
            let l: String?
            let s: String?
        }
    }

    struct Budget: Codable, Hashable {
        let name: String
        let average: String
    }

    struct Genre: Codable, Hashable {
        let name: String
        let `catch`: String
    }

    struct URLs: Codable, Hashable {
        let pc: String
    }

    struct CouponURLs: Codable, Hashable {
        let pc: String?
        let sp: String?
    }

    // CodingKeysでAPIのキーと対応付け
    enum CodingKeys: String, CodingKey {
        case id, name, address, access, lat, lng
        case logoImage = "logo_image"
        case photo, open, close, budget, genre, urls
        case coupon_urls, tel
    }
}
