# 🌲 フォレストGIS — 森林管理アプリ

**山間部の電波圏外でも、林業現場の調査業務を Android スマホ 1 台で完結。**

[![Flutter](https://img.shields.io/badge/Flutter-3.38+-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Google Play](https://img.shields.io/badge/Google%20Play-v1.2-brightgreen.svg)](#)

---

## 🎯 特長

| 機能 | 説明 |
|------|------|
| 📵 **オフラインファースト** | 電波がなくても使える。山の中でも安心 |
| 📍 **GIS 記録** | ポイント・ライン・ポリゴンを地図に直接記録 |
| 🌳 **林業実務対応** | 樹種・樹高・直径に加え、**材積・樹齢・林班・樹勢・方位・間伐対象**まで記録 |
| 📐 **プロット調査** | 標本区（円形/方形）を地図上に作成、内包樹木を集計 |
| 📊 **統計レポート** | 樹種別・林班別・間伐シミュレーション (PDF 出力可) |
| 📸 **写真台帳** | 現地写真を PDF に埋め込んだ調査台帳を生成 |
| 📏 **測定機能** | 距離・面積をリアルタイム計算 |
| 🛤️ **GPS トラック** | 踏査経路を自動記録 |
| 📤 **データ出力** | CSV・GPX・JPEG・**PDF** でエクスポート |
| ☁️ **クラウド同期 (任意)** | オンライン復帰時に自動同期、ローカルだけでも完結 |

---

## 📱 配信状況

| バージョン | 状態 | 内容 |
|---|---|---|
| **v1.2** | ✅ Google Play 配信中 | 基本機能、Summary Dashboard、現在地、編集・削除 |
| **v1.3** | 🚧 リリース準備中 (main 完了) | **Phase 3 機能群**（プロット調査、統計レポート、PDF、Tree モデル拡張）|

> v1.3 はリリース前検証中です。詳細な開発状況は [`plan.md`](plan.md) を参照してください。

---

## 🚀 クイックスタート

### 必要なもの
- Android 8.0+ (iOS は将来対応予定)
- 位置情報サービス有効

### インストール
1. [Google Play](https://play.google.com/) からダウンロード
2. （任意）アカウント作成でクラウド同期。**ローカルだけでも使えます**
3. 作業エリアを登録
4. 現場で調査開始！

---

## 💡 使い方

### 基本操作
| 操作 | 説明 |
|------|------|
| 地図タップ | ポイント/ライン/ポリゴン追加（描画モード時） |
| 樹木追加 FAB | 16 項目の入力フォームを表示（タブ UI） |
| プロット追加 FAB | 円形/方形のプロットを地図上に配置 |
| 📍 ボタン | 現在地に移動 |
| 🧭 ボタン | 追尾モード ON/OFF |
| 📤 ボタン | データエクスポート (CSV/GPX/JPEG) |
| 作業エリア ⋮ メニュー | プロット一覧 / 統計レポート / PDF 出力 |

### 描画ツール
| アイコン | 機能 |
|----------|------|
| ● | ポイント追加 |
| ─ | ライン描画（距離測定） |
| ⬡ | ポリゴン描画（面積測定） |
| 🌳 | 樹木登録（タブ UI で詳細入力） |
| □ | プロット作成（円形/方形） |

### 樹木登録フィールド (v1.3〜)

| カテゴリ | フィールド |
|---|---|
| 基本 | 樹種 / 樹高 / 胸高直径 / 健康状態 |
| 林業詳細 | 林班 / 小班 / 立木番号 / 樹齢 / 樹勢 (A/B/C) / 間伐対象フラグ |
| 環境 | 病虫害 / 傾斜角度 / 方位 (8 方位) |
| 写真 | カメラ撮影 / ギャラリー選択 |
| 備考 | 自由テキスト |
| 自動計算 | 材積 (V = 0.000045 × D² × H、二変数式) |

---

## 🛠️ 開発者向け

### 技術スタック

- **フレームワーク**: Flutter (Dart 3.10+)
- **状態管理**: Riverpod
- **地図**: flutter_map + OpenStreetMap / 国土地理院タイル
- **ローカル DB**: Drift (SQLite、コード生成、Web 対応)
- **バックエンド**: Supabase (PostgreSQL + PostGIS + Auth + Storage)
- **PDF**: pdf + printing
- **クロスプラットフォーム抽象**: `lib/core/platform/` (file_saver / file_reader / image_source / location_guard / platform_check)

### セットアップ

```bash
# 依存関係インストール
flutter pub get

# Drift などのコード生成
dart run build_runner build --delete-conflicting-outputs

# 実行（Android 接続デバイスまたはエミュレータ）
flutter run -d <device-id>

# 静的解析 (PR 前必須)
flutter analyze

# DB マイグレーション自動検証 (スキーマ変更時必須)
flutter test test/migration_test.dart
```

### プロジェクト構成

```
lib/
├── core/
│   ├── database/         # Drift スキーマ + 自動生成コード
│   └── platform/         # Web 安全な抽象 (file_saver/reader、image_source 等)
├── features/
│   ├── auth/             # 認証 (Supabase)
│   ├── backup/           # バックアップ
│   ├── export/           # CSV/GPX/JPEG エクスポート
│   ├── feedback/         # フィードバック送信
│   ├── license/          # ライセンス階層管理
│   ├── map/              # 地図・GIS・樹木（中核）
│   ├── offline/          # 同期処理
│   ├── pdf/              # PDF 生成（調査野帳/材積/写真台帳）
│   ├── plot/             # プロット調査
│   ├── settings/         # 設定画面
│   └── statistics/       # 統計レポート
test/
├── migration_test.dart   # DB マイグレーション自動検証
└── generated_migrations/ # Drift schema test helper (auto-generated)
drift_schemas/            # スキーマ snapshot (バージョン毎)
docs/
├── privacy_policy.md
└── store_listing.md
plan.md                   # 開発計画・進捗・課題の俯瞰 (← 推奨参照先)
```

### DB マイグレーションを追加する手順

```bash
# 1. app_database.dart の schemaVersion バンプ + onUpgrade 追加
# 2. build_runner で .g.dart 再生成
dart run build_runner build --delete-conflicting-outputs
# 3. 新バージョンの schema を dump
dart run drift_dev schema dump lib/core/database/app_database.dart drift_schemas/
# 4. migration test helper 再生成
dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
# 5. test/migration_test.dart にテストケース追加 → 実行
flutter test test/migration_test.dart
```

---

## 🔮 ロードマップ

詳細は [`plan.md`](plan.md) の Section 8 参照。

### v1.3 (リリース準備中)
- [x] Phase 3 機能群の main 統合
- [x] DB マイグレーション v3→v5 自動検証
- [x] PDF 写真台帳 (実画像埋め込み)
- [x] Web プラットフォーム抽象基盤
- [ ] Supabase プロジェクト復旧
- [ ] 実機 UI スモークテスト
- [ ] Google Play 公開

### v1.4 (中期)
- [ ] License 状態 UI / アップグレードフロー
- [ ] 間伐シミュレーションの実数値化
- [ ] 多言語化 (intl + arb、日/英)
- [ ] 同期競合解決フロー
- [ ] バックエンド層 Web 安全化

### v2.0 (長期)
- [ ] Flutter Web ビルド対応
- [ ] Web 管理画面 (組織運用)
- [ ] AI 材積推定
- [ ] 3D 地形オーバーレイ
- [ ] iOS 対応

---

## 📄 ライセンス

MIT License - 詳細は [LICENSE](LICENSE) を参照

---

## 🙏 謝辞

- [OpenStreetMap](https://www.openstreetmap.org/) - 地図データ
- [国土地理院](https://maps.gsi.go.jp/) - 地形図タイル
- [Supabase](https://supabase.com/) - バックエンドインフラ
- [Drift](https://drift.simonbinder.eu/) - SQLite ORM
- [pdf / printing](https://pub.dev/packages/pdf) - PDF 生成
