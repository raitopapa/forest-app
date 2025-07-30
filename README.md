# 森林管理GISアプリケーション

国土地理院地図APIを活用した包括的な森林管理システム

## 機能概要

### 🌲 主要機能
- **GIS地図表示**: 国土地理院の標準地図、衛星画像、地形図に対応
- **GPS位置追跡**: リアルタイム位置情報とGPS軌跡記録
- **樹木管理**: 位置情報付き樹木登録・健康状態管理
- **作業エリア管理**: ポリゴンベースのエリア区分管理
- **データ分析**: 統計情報と可視化
- **写真機能**: 樹木の写真撮影・保存
- **レポート生成**: PDF形式での詳細レポート出力
- **データエクスポート**: JSON/CSV形式でのデータ出力

### 🗺️ GIS機能
- **ベクターレイヤー**: ポイント、ライン、ポリゴンの描画・編集
- **距離測定**: 2点間距離の正確な測定
- **面積計算**: ポリゴンエリアの面積算出
- **等高線表示**: 地形情報の詳細表示
- **オフライン対応**: 地図データのローカル保存

### 📊 分析機能
- 樹木健康状態統計
- 作業エリア別集計
- 樹種分布分析
- GPS軌跡分析
- 森林密度計算

## 技術仕様

### バックエンド
- **フレームワーク**: FastAPI (Python)
- **データベース**: MongoDB
- **API**: RESTful API
- **ファイル処理**: 写真アップロード対応
- **レポート**: ReportLab (PDF生成)

### フロントエンド
- **フレームワーク**: React 18
- **地図ライブラリ**: React Leaflet
- **UI**: Tailwind CSS
- **アイコン**: Lucide React
- **状態管理**: React Hooks

### 地図サービス
- **国土地理院地図API**: 無料利用
- **対応レイヤー**: 
  - 標準地図 (std)
  - 衛星画像 (seamlessphoto)
  - 地形図 (relief)
  - 等高線 (gazo4)

## セットアップ

### 環境要件
- Python 3.8+
- Node.js 14+
- MongoDB
- Yarn

### インストール

1. **依存関係のインストール**
```bash
# バックエンド
cd backend
pip install -r requirements.txt

# フロントエンド
cd frontend
yarn install
```

2. **環境変数の設定**
```bash
# backend/.env
MONGO_URL=mongodb://localhost:27017
DATABASE_NAME=forest_management
GSI_API_BASE_URL=https://cyberjapandata.gsi.go.jp

# frontend/.env
REACT_APP_BACKEND_URL=http://localhost:8001
REACT_APP_GSI_API_BASE_URL=https://cyberjapandata.gsi.go.jp
```

3. **MongoDB の起動**
```bash
mongod --dbpath /data/db
```

4. **アプリケーションの起動**
```bash
# Supervisor使用
supervisord -c supervisord.conf

# または個別起動
# バックエンド
cd backend && uvicorn server:app --reload --host 0.0.0.0 --port 8001

# フロントエンド
cd frontend && yarn start
```

## API エンドポイント

### 樹木管理
- `GET /api/trees` - 樹木一覧取得
- `POST /api/trees` - 新規樹木登録
- `PUT /api/trees/{id}` - 樹木情報更新
- `DELETE /api/trees/{id}` - 樹木削除
- `POST /api/trees/{id}/photos` - 写真アップロード

### 作業エリア管理
- `GET /api/work-areas` - エリア一覧取得
- `POST /api/work-areas` - 新規エリア作成
- `PUT /api/work-areas/{id}` - エリア更新
- `DELETE /api/work-areas/{id}` - エリア削除

### GPS機能
- `GET /api/gps-tracks` - GPS軌跡取得
- `POST /api/gps-tracks` - GPS軌跡保存
- `DELETE /api/gps-tracks/{id}` - 軌跡削除

### 分析・レポート
- `GET /api/analytics/summary` - 統計サマリー
- `GET /api/analytics/species-distribution` - 樹種分布
- `GET /api/reports/generate/{type}` - PDFレポート生成
- `GET /api/export/{format}` - データエクスポート

## データ構造

### 樹木データ
```json
{
  "id": "uuid",
  "species": "樹種名",
  "health": "healthy|warning|critical",
  "lat": 35.6762,
  "lng": 139.6503,
  "diameter": 45.5,
  "height": 15.2,
  "notes": "備考",
  "photos": [],
  "created_at": "2024-01-01T00:00:00Z",
  "updated_at": "2024-01-01T00:00:00Z"
}
```

### 作業エリアデータ
```json
{
  "id": "uuid",
  "name": "エリア名",
  "status": "active|maintenance|completed",
  "boundary": [[lat, lng], ...],
  "description": "説明",
  "tree_count": 45,
  "created_at": "2024-01-01T00:00:00Z"
}
```

## 使用方法

### 1. 樹木の登録
1. 地図上で位置を確認
2. 「+」ボタンから新規樹木登録
3. 樹種、健康状態、サイズを入力
4. 写真の撮影・添付（オプション）

### 2. エリアの設定
1. ポリゴン描画モードを選択
2. 地図上でエリア境界を描画
3. エリア名と状態を設定
4. 保存

### 3. GPS追跡
1. 「GPS開始」ボタンでトラッキング開始
2. 移動軌跡が自動記録
3. 「GPS停止」で記録終了・保存

### 4. データ分析
1. 「分析」タブで統計情報を確認
2. 樹木健康状態、エリア別データを表示
3. グラフ・チャートで可視化

### 5. レポート生成
1. 「データ」タブからレポート生成
2. PDF形式でダウンロード
3. 分析結果を含む詳細レポート

## ライセンス

このプロジェクトはMITライセンスの下で公開されています。

## 使用地図について

国土地理院地図を使用しています。
- 出典：国土地理院ウェブサイト (https://maps.gsi.go.jp/)
- 利用規約に従ってご利用ください

## サポート

バグ報告や機能要望は Issues にて受け付けています。