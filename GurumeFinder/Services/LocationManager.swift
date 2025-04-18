//
//  LocationManager.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/06.
//

//
//  LocationManager.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/06.
//

import SwiftUI
import Foundation
import CoreLocation

enum LocationError: Error {
    case notAvailable
    case notAuthorized
    case unknown(Error?)
}

@Observable class LocationManager: NSObject, CLLocationManagerDelegate {
    private let locationManager = CLLocationManager()
    var location: CLLocation? // 現在地
    var authorizationStatus: CLAuthorizationStatus // 認証状態
    var locationError: LocationError? // 位置情報エラー

    override init() {
        authorizationStatus = locationManager.authorizationStatus
        locationError = nil
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest // 最高精度
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization() // 利用中のみ許可リクエスト
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation() // 位置情報更新開始
        locationError = nil
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation() // 位置情報更新停止
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last // 最新の位置情報
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = .unknown(error) // エラーを記録
        stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        locationError = nil

        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation() // 許可時、更新開始
        } else {
            stopUpdatingLocation()
            if status == .denied || status == .restricted {
                locationError = .notAuthorized // 未許可エラー
            }
        }
    }
}
