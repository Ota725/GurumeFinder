//
//  RestaurantDetailView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/06.
//

import SwiftUI
import MapKit

// 飲食店詳細画面
struct RestaurantDetailView: View {
    let restaurant: Restaurant
    @State private var showMapApp = false
    @State private var showPhoneApp = false

    // MARK: - ビューコンポーネント

    // 店舗画像セクション
    private var restaurantImageSection: some View {
        Group {
            if let imageUrl = restaurant.photo.mobile.l, let _ = URL(string: imageUrl) {
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
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
        .clipped()
    }

    // ジャンルと予算セクション
    private var restaurantCategoryAndBudgetSection: some View {
        HStack {
            Label(restaurant.genre.name, systemImage: "fork.knife")
            Spacer()
            Label(restaurant.budget.name, systemImage: "yensign.circle")
        }
        .foregroundColor(.primary)
    }

    // 住所セクション
    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            infoSection(title: "住所", content: restaurant.address)

            Button(action: {
                showMapApp = true
            }) {
                Label("地図で見る", systemImage: "map")
                    .padding(.vertical, 8)
            }
        }
    }

    // 営業時間と定休日セクション
    private var businessHoursSection: some View {
        Group {
            infoSection(title: "営業時間", content: restaurant.open)

            if let close = restaurant.close, !close.isEmpty {
                infoSection(title: "定休日", content: close)
            }
        }
    }

    // クーポンリンク
    private func couponLink(url: String) -> some View {
        Link(destination: URL(string: url)!) {
            Label("クーポンを見る", systemImage: "ticket")
                .padding(.vertical, 8)
        }
    }

    // MARK: - ヘルパーメソッド

    // 電話をかける処理
    private func handlePhoneCall(isActive: Bool) {
        if isActive, let tel = restaurant.tel, let url = URL(string: "tel://\(tel.replacingOccurrences(of: "-", with: ""))") {
            UIApplication.shared.open(url)
            showPhoneApp = false
        }
    }

    // MARK: - body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 店舗画像
                restaurantImageSection

                // 店舗情報セクション
                VStack(alignment: .leading, spacing: 12) {
                    // 店舗名
                    Text(restaurant.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()

                    // ジャンルと予算
                    restaurantCategoryAndBudgetSection

                    Divider()

                    // 住所情報
                    addressSection

                    Divider()

                    // アクセス情報
                    infoSection(title: "アクセス", content: restaurant.access)

                    Divider()

                    // 営業時間と定休日
                    businessHoursSection

                    Divider()

                    // ホットペッパーリンク
                    Link(destination: URL(string: restaurant.urls.pc)!) {
                        Label("ホットペッパーでさらに詳しく", systemImage: "globe")
                            .padding(.vertical, 8)
                    }

                    // クーポン情報（存在する場合）
                    if let couponURL = restaurant.coupon_urls?.sp, !couponURL.isEmpty {
                        Divider()
                        couponLink(url: couponURL)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("店舗詳細")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showMapApp) {
            EnhancedMapView(
                latitude: restaurant.lat,
                longitude: restaurant.lng,
                name: restaurant.name,
                address: restaurant.address,
                access: restaurant.access,
                isPresented: $showMapApp
            )
        }
        .onChange(of: showPhoneApp) { oldValue, newValue in
            handlePhoneCall(isActive: newValue)
        }
    }
}

// MARK: - 拡張されたマップビュー
struct EnhancedMapView: View {
    // MARK: プロパティ
    let latitude: Double
    let longitude: Double
    let name: String
    let address: String
    let access: String
    @Binding var isPresented: Bool

    // 閉じるボタン - コンポーネント化
    private var dismissButton: some View {
        Button {
            isPresented = false
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
        }
    }

    // MARK: - body
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // マップ表示
                MapViewRepresentable(
                    latitude: latitude,
                    longitude: longitude,
                    name: name
                )
                .frame(maxWidth: .infinity)
                .frame(height: UIScreen.main.bounds.height * 0.6)

                // 住所とアクセス情報
                VStack(alignment: .leading, spacing: 16) {
                    // 共通化したinfoSectionを使用
                    infoSection(title: "住所", content: address)
                    infoSection(title: "アクセス", content: access)
                }
                .padding()
                .background(Color(.systemBackground))
            }
            .navigationTitle("お店の地図")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    dismissButton
                }
            }
        }
    }
}

// MARK: - マップビューのUIViewRepresentable
struct MapViewRepresentable: UIViewRepresentable {
    // MARK: プロパティ
    let latitude: Double
    let longitude: Double
    let name: String

    /// 座標を計算するプロパティ
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // MARK: UIViewRepresentable実装
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // マップの表示領域を設定
        configureMapRegion(for: uiView)

        // アノテーション（ピン）を追加
        addAnnotation(to: uiView)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - ヘルパーメソッド

    /// マップ表示領域を設定
    private func configureMapRegion(for mapView: MKMapView) {
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        mapView.setRegion(region, animated: true)
    }

    /// アノテーション（ピン）を追加
    private func addAnnotation(to mapView: MKMapView) {
        // 以前のアノテーションをクリア
        mapView.removeAnnotations(mapView.annotations)

        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = name
        mapView.addAnnotation(annotation)
    }

    // MARK: - コーディネーター
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable

        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }

        // アノテーションビューのカスタマイズ
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "RestaurantPin"

            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.canShowCallout = true

                let btn = UIButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = btn
            } else {
                annotationView?.annotation = annotation
            }

            return annotationView
        }

        // 詳細ボタンがタップされた時の処理
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            // マップアイテムを作成
            let mapItem = createMapItem()

            // 車での経路案内をデフォルトに設定
            let launchOptions: [String: Any] = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            mapItem.openInMaps(launchOptions: launchOptions)
        }

        // マップアイテム作成メソッド（共通化）
        private func createMapItem() -> MKMapItem {
            let placemark = MKPlacemark(coordinate: parent.coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = parent.name
            return mapItem
        }
    }
}

// 汎用情報セクション
private func infoSection(title: String, content: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(title)
            .font(.headline)
        Text(content)
            .font(.body)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#Preview {
    ContentView()
}
