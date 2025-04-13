//
//  LocationManager.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/06.
//

import CoreLocation
import SwiftUI
//
//struct Location {
//    let latitude: Double
//    let longitude: Double
//}
//// ユーザーの位置情報を管理・取得するためのクラス
//@Observable
//class LocationManager: NSObject, CLLocationManagerDelegate {
//    private let locationManager = CLLocationManager()
//
//    // UIに位置情報の更新を通知するためのプロパティ
//    var location: CLLocation? = nil
//
//    override init() {
//        super.init()
//        // 自分自身を位置情報のデリゲートに設定（コールバックを受け取るため）
//        self.locationManager.delegate = self
//        // ユーザーに位置情報の使用許可をリクエスト（アプリ使用中）
//        self.locationManager.requestWhenInUseAuthorization()
//        // 位置情報の取得を開始（継続的に位置情報を受け取るため）
//        self.locationManager.startUpdatingLocation()
//    }
//
//    // 位置情報が更新されたときに呼ばれる
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        // 最新の位置情報を保持（UI側が最新情報を参照できるようにする）
//        if let location = locations.last {
//            self.location = location
//        }
//    }
//
//}

import Foundation
import CoreLocation

@Observable class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()

    var location: CLLocation?
    var authorizationStatus: CLAuthorizationStatus

    override init() {
        authorizationStatus = locationManager.authorizationStatus

        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    // CLLocationManagerDelegateメソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status

        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        }
    }
}

