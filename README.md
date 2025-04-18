# 簡易仕様書

### 作者
太田陽菜
### アプリ名
GurumeFinder

#### コンセプト
食べに行きたいお店がすぐ見つかる！

#### こだわったポイント
近くのお店はアプリを起動してすぐに表示されるようにしました。

### 該当プロジェクトのリポジトリ URL
[https://github.com/xxxx](https://github.com/Ota725/GurumeFinder/)

## 開発環境
### 開発環境
Xcode 16.3

### 開発言語
Swift 5

## 動作対象端末・OS
### 動作対象OS
iOS 18.4

## 開発期間
10日間

## アプリケーション機能

APIキーはConfig.xcconfigに以下のように記述しました。
HOTPEPPER_API_KEY = APIキー

### 機能一覧
- レストラン検索：ホットペッパーグルメサーチAPIを使用して、現在地周辺の飲食店を検索する。
- レストラン情報取得：ホットペッパーグルメサーチAPIを使用して、飲食店の詳細情報を取得する。
- マップ表示：飲食店の所在地をマップで確認する。

### 画面一覧
- ホーム画面 ：現在地周辺のレストランを検索し、一覧表示する。
- 一覧画面 ：検索結果の飲食店を一覧表示する。
- レストラン詳細画面 ：APIで取得したレストランの詳細情報を表示する。
- 詳細検索画面 ：条件を指定してレストランを検索する。(未実装)

### 今後実装すべき機能
- 詳細検索画面 ：エリア・ジャンル、予算、こだわりなどで詳細検索機能
エリア情報にAPIのデータを用いる予定だったがエリア情報を保存する処理が難しく実装まで至らなかった。
- ホーム画面 ：位置情報を「許可しない」にした場合に設定画面に遷移するボタンの実装

### 使用しているAPI,SDK,ライブラリなど
- ホットペッパーグルメサーチAPI
- Kingfisher

### 技術面でアドバイスして欲しいポイント
- APIで取得したエリア情報を詳細検索に組み込みたい。
- キャッシュを用いて不要な読み込みを無くしたい。

## 自己評価
最低要件は満たせたが自分の理想の実装はできなかった。
viewModelなどのアプリの設計がとても難しかった。
実際に制作してみると状態管理や細かい挙動の制御など大変勉強になった。

