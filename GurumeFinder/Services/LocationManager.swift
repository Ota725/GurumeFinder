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

    var location: CLLocation?
    var authorizationStatus: CLAuthorizationStatus
    var locationError: LocationError? // LocationError を保持するプロパティ

    override init() {
        authorizationStatus = locationManager.authorizationStatus
        locationError = nil // 初期化

        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
    }

    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
        locationError = nil // 位置情報更新開始時にエラーをクリア
    }

    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
    }

    // CLLocationManagerDelegateメソッド
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        location = locations.last
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = .unknown(error) // 位置情報取得失敗時に LocationError を設定
        stopUpdatingLocation() // エラー発生時は位置情報更新を停止することが望ましい
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        authorizationStatus = status
        locationError = nil // 認証状態変更時にエラーをクリア

        if status == .authorizedWhenInUse || status == .authorizedAlways {
            locationManager.startUpdatingLocation()
        } else {
            // 許可されなかった場合は位置情報更新を停止
            stopUpdatingLocation()
            if status == .denied || status == .restricted {
                locationError = .notAuthorized
            }
        }
    }
}
