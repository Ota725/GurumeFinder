//
//  RestaurantDetailView.swift
//  GurumeFinder
//
//  Created by 太田陽菜 on 2025/04/06.
//

import SwiftUI
import MapKit

// MARK: - RestaurantDetailView 概要
// 渡された `Restaurant` オブジェクトの詳細情報を表示する画面。
// 店舗画像、基本情報（店名、ジャンル、予算）、住所、アクセス、営業時間、
// 外部リンク（ホットペッパー、クーポン）などを表示します。
// 「地図で見る」ボタンタップで `EnhancedMapView` をシート表示します。
// 電話発信機能のための状態変数 (`showPhoneApp`) もありますが、
// 現在これを `true` にするUI要素は見当たりません (要実装)。
//
// 関連コンポーネント:
// - EnhancedMapView: 地図と住所/アクセス情報を表示するシート用View。
// - MapViewRepresentable: UIKitのMKMapViewをSwiftUIで表示するためのラッパー。
// - infoSection: タイトルと内容を表示する共通UIヘルパー関数。

struct RestaurantDetailView: View {
    // 表示対象のレストランデータ (外部から注入)
    let restaurant: Restaurant
    // 地図シート (EnhancedMapView) の表示状態を管理
    @State private var showMapApp = false
    // 電話アプリ起動のトリガー (現状、これをtrueにするUIはない)
    @State private var showPhoneApp = false

    // MARK: - ビューコンポーネント (Private Properties)

    // 店舗画像セクション (AsyncImageで非同期読み込み)
    private var restaurantImageSection: some View {
        Group {
            // 有効な画像URLがある場合
            if let imageUrl = restaurant.photo.mobile.l, let url = URL(string: imageUrl) {
                AsyncImage(url: url) { image in
                    image.resizable().aspectRatio(contentMode: .fill)
                } placeholder: {
                    // 読み込み中や失敗時はグレーのプレースホルダーを表示
                    Rectangle().foregroundColor(.gray)
                }
                .frame(height: 200) // 高さを固定
                .clipped() // フレーム外にはみ出した部分をクリップ
            } else {
                // 画像URLがない場合は「画像なし」表示
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 120) // 画像がない場合は少し高さを抑える
                    .overlay(Text("画像なし"))
            }
        }
        .frame(maxWidth: UIScreen.main.bounds.width)
        .clipped()
    }

    // ジャンルと予算セクション (Labelで見やすく表示)
    private var restaurantCategoryAndBudgetSection: some View {
        HStack {
            Label(restaurant.genre.name, systemImage: "fork.knife")
            Spacer()
            Label(restaurant.budget.name, systemImage: "yensign.circle")
        }
        .foregroundColor(.primary)
    }

    // 住所セクション (住所表示と地図表示ボタン)
    private var addressSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 共通ヘルパー関数で住所を表示
            infoSection(title: "住所", content: restaurant.address)

            // 「地図で見る」ボタン: タップで地図シートを表示
            Button {
                showMapApp = true // これにより .sheet がトリガーされる
            } label: {
                Label("地図で見る", systemImage: "map")
                    .padding(.vertical, 8) // タップ領域を確保
            }
        }
    }

    // 営業時間と定休日セクション
    private var businessHoursSection: some View {
        Group {
            // 共通ヘルパー関数で営業時間を表示
            infoSection(title: "営業時間", content: restaurant.open)

            // 定休日情報が存在し、空でない場合のみ表示
            if let close = restaurant.close, !close.isEmpty {
                infoSection(title: "定休日", content: close)
            }
        }
    }

    // クーポンリンク (共通化)
    private func couponLink(url: String) -> some View {
        // 有効なURL文字列からURLオブジェクトを生成できる前提
        Link(destination: URL(string: url)!) {
            Label("クーポンを見る", systemImage: "ticket")
                .padding(.vertical, 8)
        }
    }

    // MARK: - ヘルパーメソッド (アクション)

    // 電話をかける処理 (onChange(of: showPhoneApp) から呼ばれる想定)
    private func handlePhoneCall(isActive: Bool) {
        // isActiveがtrue、電話番号が存在し、tel:// スキームのURLが生成できる場合
        if isActive, let tel = restaurant.tel, let url = URL(string: "tel://\(tel.replacingOccurrences(of: "-", with: ""))") {
            // 電話アプリを開く
            UIApplication.shared.open(url)
            // 処理後にフラグをリセット (しないと再度onChangeが呼ばれない)
            showPhoneApp = false
        }
    }

    // MARK: - body
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // 1. 店舗画像
                restaurantImageSection

                // 2. 店舗情報セクション (Padding適用)
                VStack(alignment: .leading, spacing: 12) {
                    // 店舗名
                    Text(restaurant.name)
                        .font(.title).fontWeight(.bold)
                    // 長い場合に折り返す設定
                        .fixedSize(horizontal: false, vertical: true)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Divider()

                    // ジャンルと予算
                    restaurantCategoryAndBudgetSection

                    Divider()

                    // 住所情報と地図ボタン
                    addressSection

                    Divider()

                    // アクセス情報
                    infoSection(title: "アクセス", content: restaurant.access)

                    Divider()

                    // 営業時間と定休日
                    businessHoursSection

                    Divider()

                    // ホットペッパー詳細ページへのリンク
                    // 有効なURL文字列からURLオブジェクトを生成できる前提
                    Link(destination: URL(string: restaurant.urls.pc)!) {
                        Label("ホットペッパーでさらに詳しく", systemImage: "globe")
                            .padding(.vertical, 8)
                    }

                    // クーポンURL(sp)が存在する場合のみクーポンリンクを表示
                    if let couponURL = restaurant.coupon_urls?.sp, !couponURL.isEmpty {
                        Divider()
                        couponLink(url: couponURL)
                    }
                }
                .padding() // このVStack全体にパディングを適用
            }
        }
        .navigationTitle("店舗詳細")
        .navigationBarTitleDisplayMode(.inline) // タイトルを小さく表示
        // 「地図で見る」ボタンで $showMapApp が true になると、このシートが表示される
        .sheet(isPresented: $showMapApp) {
            // 地図表示用のカスタムViewを呼び出し、必要な情報を渡す
            EnhancedMapView(
                latitude: restaurant.lat,
                longitude: restaurant.lng,
                name: restaurant.name,
                address: restaurant.address,
                access: restaurant.access,
                isPresented: $showMapApp // シート自身を閉じるためにバインディングを渡す
            )
        }
        // 電話発信トリガー ($showPhoneApp) の変更を監視
        // 注意: 現在、showPhoneApp を true にするボタン等がないため、この処理は呼ばれない
        .onChange(of: showPhoneApp) { oldValue, newValue in
            handlePhoneCall(isActive: newValue)
        }
    }
}

// MARK: - EnhancedMapView 概要
// RestaurantDetailViewからシート表示される地図と追加情報（住所、アクセス）のView。
// MapViewRepresentable を使って地図を表示し、下部に情報をリスト表示します。
// 自身を閉じるためのBinding<Bool>を受け取ります。

struct EnhancedMapView: View {
    // MARK: プロパティ (外部から注入)
    let latitude: Double
    let longitude: Double
    let name: String
    let address: String
    let access: String
    // シートの表示状態を制御するためのバインディング (自身を閉じるために使用)
    @Binding var isPresented: Bool

    // 閉じるボタン (UIコンポーネントとして抽出)
    private var dismissButton: some View {
        Button {
            isPresented = false // isPresentedをfalseにしてシートを閉じる
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 14, weight: .bold))
        }
    }

    // MARK: - body
    var body: some View {
        // シート内で独自のナビゲーションバーを持つために NavigationStack を使用
        NavigationStack {
            VStack(spacing: 0) {
                // UIKitのMKMapViewを表示するためのラッパーView
                MapViewRepresentable(
                    latitude: latitude,
                    longitude: longitude,
                    name: name
                )
                .frame(maxWidth: .infinity)
                // 画面高さの約60%を地図表示領域とする
                .frame(height: UIScreen.main.bounds.height * 0.6)

                // 住所とアクセス情報を表示するセクション
                VStack(alignment: .leading, spacing: 16) {
                    // RestaurantDetailView と同じ共通ヘルパー関数を利用
                    infoSection(title: "住所", content: address)
                    infoSection(title: "アクセス", content: access)
                }
                .padding()
                .background(Color(.systemBackground)) // 背景色
            }
            .navigationTitle("お店の地図")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // ナビゲーションバー左上に閉じるボタンを配置
                ToolbarItem(placement: .topBarLeading) {
                    dismissButton
                }
            }
        }
    }
}

// MARK: - MapViewRepresentable 概要
// UIKit の MKMapView を SwiftUI View として利用するための UIViewRepresentable 実装。
// 指定された座標に地図を表示し、店舗名のアノテーション（ピン）を立てます。
// アノテーションのコールアウト（吹き出し）には詳細ボタンが表示され、
// タップすると標準マップアプリで経路案内を開始します。

struct MapViewRepresentable: UIViewRepresentable {
    // MARK: プロパティ (外部から注入)
    let latitude: Double
    let longitude: Double
    let name: String

    /// 緯度経度から CLLocationCoordinate2D を生成する算出プロパティ
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    // MARK: UIViewRepresentable プロトコルメソッド実装

    // MKMapViewのインスタンスを生成
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        // デリゲートとしてCoordinatorを設定 (アノテーションのカスタマイズ等を行うため)
        mapView.delegate = context.coordinator
        return mapView
    }

    // SwiftUI側の状態変更に応じてMKMapViewを更新
    func updateUIView(_ uiView: MKMapView, context: Context) {
        // 1. 表示領域 (中心座標と縮尺) を設定
        configureMapRegion(for: uiView)
        // 2. アノテーション (ピン) を追加 (既存があれば一旦削除してから追加)
        addAnnotation(to: uiView)
    }

    // Coordinatorインスタンスを生成
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - ヘルパーメソッド (MKMapView操作)

    /// マップの表示領域（中心座標と縮尺）を設定する
    private func configureMapRegion(for mapView: MKMapView) {
        // 表示する縮尺 (値が小さいほど拡大)
        let span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        // 中心座標と縮尺から表示領域を作成
        let region = MKCoordinateRegion(center: coordinate, span: span)
        // マップビューに表示領域を設定 (アニメーション付き)
        mapView.setRegion(region, animated: true)
    }

    /// アノテーション（ピン）を追加する
    private func addAnnotation(to mapView: MKMapView) {
        // 既存のアノテーションがあれば全て削除 (updateUIViewが呼ばれるたびに重複して追加されるのを防ぐ)
        mapView.removeAnnotations(mapView.annotations)

        // 新しいアノテーションを作成
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate // 座標を設定
        annotation.title = name // コールアウトに表示するタイトルを設定
        // マップビューにアノテーションを追加
        mapView.addAnnotation(annotation)
    }

    // MARK: - Coordinator (MKMapViewDelegate)
    // MKMapViewからのイベント (デリゲートメソッド呼び出し) を処理するクラス
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable // 親View (MapViewRepresentable) への参照

        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }

        // アノテーションビュー（ピンの外観）を生成・カスタマイズするデリゲートメソッド
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let identifier = "RestaurantPin" // 再利用のためのID

            // 再利用可能なアノテーションビューを取得
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier)

            if annotationView == nil {
                // 再利用可能なビューがない場合は新規作成 (MKMarkerAnnotationView: 標準的なピン)
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                // コールアウト (吹き出し) を表示可能にする
                annotationView?.canShowCallout = true
                // コールアウト右側に情報ボタン (i) を追加
                let btn = UIButton(type: .detailDisclosure)
                annotationView?.rightCalloutAccessoryView = btn
            } else {
                // 再利用ビューがある場合は、アノテーション情報だけ更新
                annotationView?.annotation = annotation
            }

            return annotationView
        }

        // アノテーションのコールアウト右側のボタンがタップされた時に呼ばれるデリゲートメソッド
        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
            // 経路案内のためのMapItemを作成
            let mapItem = createMapItem()

            // マップアプリ起動オプション: 経路案内モードを「車」に指定
            let launchOptions: [String: Any] = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
            // 標準マップアプリを開き、経路案内を開始
            mapItem.openInMaps(launchOptions: launchOptions)
        }

        // MKMapItem を作成するヘルパーメソッド (共通化)
        private func createMapItem() -> MKMapItem {
            // 座標情報から MKPlacemark を作成
            let placemark = MKPlacemark(coordinate: parent.coordinate)
            // Placemark から MKMapItem を作成
            let mapItem = MKMapItem(placemark: placemark)
            // マップアプリで表示される名称を設定
            mapItem.name = parent.name
            return mapItem
        }
    }
}

// MARK: - 共通情報セクションヘルパー関数
// タイトルと内容テキストを縦に並べて表示する共通UIコンポーネント。
// RestaurantDetailView と EnhancedMapView で再利用される。
private func infoSection(title: String, content: String) -> some View {
    VStack(alignment: .leading, spacing: 4) {
        Text(title).font(.headline) // タイトルは少し強調
        Text(content)
            .font(.body)
        // 長文の場合に折り返して表示
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading) // 左寄せ
    }
}

#Preview {
    // プレビュー用に ContentView を表示 (実際にはリスト等から遷移してくる想定)
    // Restaurant のダミーデータがあれば、そちらを使う方が望ましい
    ContentView()
    // または、ダミーデータで直接プレビュー
    // RestaurantDetailView(restaurant: Restaurant.dummyData)
}
