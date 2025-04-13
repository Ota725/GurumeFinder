//
//  RestaurantDetailView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/06.
//

import SwiftUI
import MapKit

struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @State private var showMapApp = false
    @State private var showPhoneApp = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 店舗画像
                if let imageUrl = restaurant.photo.mobile.l, let url = URL(string: imageUrl) {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Rectangle()
                            .foregroundColor(.gray)
                    }
                    .frame(height: 200)
                    .clipped()
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 120)
                        .overlay(Text("画像なし"))
                }

                // 店舗情報
                VStack(alignment: .leading, spacing: 12) {
                    Text(restaurant.name)
                        .font(.title)
                        .fontWeight(.bold)

                    Divider()

                    // ジャンルと予算
                    HStack {
                        Label(restaurant.genre.name, systemImage: "fork.knife")
                        Spacer()
                        Label(restaurant.budget.name, systemImage: "yensign.circle")
                    }
                    .foregroundColor(.secondary)

                    Divider()

                    // 住所
                    VStack(alignment: .leading, spacing: 4) {
                        Text("住所")
                            .font(.headline)
                        Text(restaurant.address)
                            .font(.body)

                        Button(action: {
                            showMapApp = true
                        }) {
                            Label("地図で見る", systemImage: "map")
                                .padding(.vertical, 8)
                        }
                    }

                    Divider()

                    // アクセス
                    VStack(alignment: .leading, spacing: 4) {
                        Text("アクセス")
                            .font(.headline)
                        Text(restaurant.access)
                            .font(.body)
                    }

                    Divider()

                    // 営業時間
                    VStack(alignment: .leading, spacing: 4) {
                        Text("営業時間")
                            .font(.headline)
                        Text(restaurant.open)
                            .font(.body)
                    }

                    if let close = restaurant.close, !close.isEmpty {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("定休日")
                                .font(.headline)
                            Text(close)
                                .font(.body)
                        }
                    }

                    Divider()

                    // 電話番号
                    if let tel = restaurant.tel, !tel.isEmpty {
                        Button(action: {
                            showPhoneApp = true
                        }) {
                            Label("電話する: \(tel)", systemImage: "phone")
                                .padding(.vertical, 8)
                        }

                        Divider()
                    }

                    // ホームページリンク
                    Link(destination: URL(string: restaurant.urls.pc)!) {
                        Label("ホットペッパーでさらに詳しく", systemImage: "globe")
                            .padding(.vertical, 8)
                    }

                    // クーポン情報
                    if let couponURL = restaurant.coupon_urls?.sp, !couponURL.isEmpty {
                        Divider()

                        Link(destination: URL(string: couponURL)!) {
                            Label("クーポンを見る", systemImage: "ticket")
                                .padding(.vertical, 8)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("店舗詳細")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showMapApp) {
            MapView(latitude: restaurant.lat, longitude: restaurant.lng, name: restaurant.name)
        }
        .onChange(of: showPhoneApp) { newValue in
            if newValue, let tel = restaurant.tel, let url = URL(string: "tel://\(tel.replacingOccurrences(of: "-", with: ""))") {
                UIApplication.shared.open(url)
                showPhoneApp = false
            }
        }
    }
}

struct MapView: UIViewRepresentable {
    let latitude: Double
    let longitude: Double
    let name: String

    // 座標を計算するプロパティを追加
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // ここでcoordinateプロパティを使用
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = name

        uiView.setRegion(region, animated: true)
        uiView.addAnnotation(annotation)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "RestaurantPin"

            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true

                let btn = UIButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = btn
            } else {
                annotationView?.annotation = annotation
            }

            return annotationView
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            // parent.coordinateを使用
            let placemark = MKPlacemark(coordinate: parent.coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = parent.name
            // launchOptionsの型を明示
            let launchOptions: [String: Any] = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
            // または単に空のDictionaryを使用することもできます
            // mapItem.openInMaps(launchOptions: [:])
        }
    }
}
