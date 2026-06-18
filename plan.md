# 開発計画 / 進捗 / 課題 — 森林管理アプリ (フォレストGIS)

> このファイルはプロジェクトの**俯瞰用ドキュメント**です。
> 「目的・方針 → 現状 → 課題 → 将来」を 1 か所に集約し、他の AI / 共同開発者と共有して開発の方向性を検証するために使います。
> **更新ルール**: 大きな PR がマージされたら「進捗」「課題」セクションを差分追記し、節目で全体を見直してください。

**最終更新**: 2026-06-18
**現在の main**: v1.3 相当（Phase 3 機能群 + Supabase 移行マージ済み、未リリース）
**Google Play 配信中**: v1.2 (commit 3b6a0a0、2026-01 リリース)

---

## 1. プロジェクトの目的とビジョン

### 1.1 一行ミッション

> **山間部の電波圏外でも、林業現場の調査業務を Android スマホ 1 台で完結できるようにする。**

### 1.2 ターゲットユーザー

- 林業従事者（森林組合、自治体林業課、個人事業主、研究者）
- 森林整備や調査の現場担当者（樹種・樹高・直径・本数の記録、間伐対象の選定など）
- 副次的に：環境系 NPO、林業教育機関、自然観察記録者

### 1.3 ビジョン（中長期）

- **短期 (v1.x)**: Android で完結する個人 / 小規模調査ツール
- **中期 (v2.x)**: Flutter Web 管理画面で複数人 / 組織運用、データ集計
- **長期 (v3.x)**: AI 材積推定（写真 → 直径推定）、3D 地形オーバーレイ、iOS 対応

---

## 2. 制約と基本方針

| 項目 | 方針 | 理由 |
|---|---|---|
| 開発体制 | **個人開発** | エンジニア 1 名 + AI 補助 (Claude / 過去は GPT) |
| コスト | **初期投資 0 円 / ランニング限りなく 0 に近く** | 個人持続性 |
| プラットフォーム | Android 主軸、iOS / Web は将来 | リリースコスト最小化 |
| **オフラインファースト** | データの読み書きは常にローカル DB、通信回復時に同期 | **山間部の圏外環境で確実に動作する必要があるため** |
| クラウド同期 | **オプショナル扱い** | Supabase Free Tier の 7 日 inactive で pause / 90 日で復元不可リスクを踏まえ、ローカル運用だけでも完結する UX を維持 |
| データモデル | PostGIS の GEOGRAPHY 型を活用、ローカルは WKT 文字列で保持 | 将来の GIS 解析（面積計算、近傍検索）に耐える設計 |

---

## 3. 技術スタック (現状)

### 3.1 フロントエンド (Mobile App)

| 領域 | 採用 | バージョン目安 | 理由 |
|---|---|---|---|
| Framework | **Flutter** (Dart) | 3.38 stable / Dart 3.10 | Android/iOS 単一コード化、型安全、エコシステム |
| 状態管理 | **Riverpod** | ^2.5 | テスタビリティ、grouping 容易 |
| 地図 | **flutter_map** | ^6.1 | 完全無料、OSM / 国土地理院タイル選択可 |
| ローカル DB | **Drift** (SQLite + コード生成) | ^2.16 | 型安全、マイグレーション API、Web 対応 |
| 写真 | image_picker, share_plus | – | OS 標準 ピッカー＋共有シート |
| GPS | geolocator | ^14 | Web の HTTPS 要件も内部抽象化 |
| PDF | pdf, printing | ^3.11 / ^5.13 | クライアント側生成（サーバ不要） |
| その他 | uuid, csv, latlong2, intl, shared_preferences, url_launcher, package_info_plus, device_info_plus | – | – |

### 3.2 バックエンド / 同期

| 領域 | 採用 | 理由 |
|---|---|---|
| BaaS | **Supabase** (PostgreSQL + PostGIS + Auth + Storage) | 初期費用 0、PostGIS で GIS 解析、Email/Password 認証 |
| 同期方式 | カスタム実装 (Drift ↔ Supabase REST) | 単方向 push + 競合フラグ管理 |
| 認証 | Email/Password | OAuth は将来 |

### 3.3 クロスプラットフォーム抽象（`lib/core/platform/`）

Web ビルド対応のため、Step 1 〜直近の改善で以下を導入：

| 抽象 | 役割 | mobile/Desktop 実装 | Web 実装 |
|---|---|---|---|
| `PlatformCheck` | `Platform.is*` の Web 安全ラッパー | `dart:io Platform` | `kIsWeb` 先評価 |
| `FileSaver` | ファイル保存 + 共有シート | path_provider + share_plus | package:web Blob + anchor.click |
| `FileReader` | パスから bytes 読込 | dart:io File.readAsBytes | null (blob URL は再現不可) |
| `ImageSourceWidget` | bytes / path / URL の優先制御付き画像 widget | Image.file fallback | Image.network / placeholder |
| `LocationGuard` | Geolocator の権限・HTTPS エラー統一 | Geolocator | 同 + HTTPS 判定 |

これにより `lib/features/map/` 配下の UI 層から **`dart:io` の直接使用はゼロ**（バックエンド系 export/sync/backup は別途）。

---

## 4. アーキテクチャ概観

```
┌──────────────────────────────────────────────┐
│ UI (lib/features/<feature>/presentation)     │
│   - WorkAreaListPage, MapPage,               │
│     TreeInputDialog, PlotListPage 等         │
└────────────┬─────────────────────────────────┘
             │
┌────────────▼─────────────────────────────────┐
│ Service / Repository (data/, services/)      │
│   - TreeRepository, PlotRepository,          │
│     StatisticsService, PdfGeneratorService   │
│     ExportService, SyncRepository            │
└────┬─────────────────────────────┬───────────┘
     │                             │
┌────▼──────┐               ┌──────▼───────────┐
│ Drift     │   sync push   │ Supabase REST    │
│ (SQLite)  │ ◀─────────────│ (PostgreSQL +    │
│ LOCAL     │               │  PostGIS, Auth,  │
│           │               │  Storage)        │
└───────────┘               └──────────────────┘
```

- **読み書きは常にローカル先**。書き込みは `syncStatus: 'dirty'` フラグで mark。
- 通信回復時に `SyncRepository.syncPush()` が dirty 行を Supabase に upsert。
- 画像は端末ローカル `photo_path` + Supabase Storage URL `photo_url` の二段持ち。

---

## 5. データモデル (v5 schema)

主要テーブル:

| テーブル | 主要カラム | 用途 |
|---|---|---|
| `LocalWorkAreas` | id, name, description, boundary (WKT POLYGON), syncStatus, updatedAt | 作業エリア (調査単位) |
| `LocalTrees` | id, species, height, diameter, healthStatus, location (WKT POINT), workAreaId, photoPath/Url, **volume, age, forestSection, subSection, treeNumber, vigor, pestDisease, slope, aspect, notes, markedForThinning, plotId**, syncStatus, updatedAt | 樹木（Phase 3 で 11 フィールド追加） |
| `LocalMapObjects` | id, name, type (point/line/polygon), geometry (WKT), description, photoPath, attributes, syncStatus, updatedAt | 描画オブジェクト |
| `LocalPlots` *(Phase 3)* | id, name, shape (circle/square), centerLat, centerLng, size, workAreaId, description, syncStatus, createdAt, updatedAt | 標本区（プロット調査） |

スキーマバージョン履歴：

| バージョン | 変更内容 |
|---:|---|
| v1 | 初版 |
| v2 | LocalMapObjects テーブル新規 |
| v3 | LocalMapObjects に photoPath / attributes 追加 |
| v4 | LocalTrees に 11 フィールド追加（材積等） |
| v5 | LocalPlots テーブル新規 + LocalTrees.plotId 追加 |

マイグレーションは **ADD COLUMN / CREATE TABLE のみ、破壊操作なし**。v3 → v5 アップグレードのデータ保持は `test/migration_test.dart` で自動検証 (PR #20)。

---

## 6. 進捗 — マージ済み 27 PR の整理

### Phase 0: 引き継ぎ整理 (2026-05-18 〜)
- ブランチ大量削除 (master, codex, work-sync など)
- main が hotfix #5 でビルド可能化
- Phase 3 WIP (web-support) を 10 ステップに分解

### Phase 3 機能移行 (PRs #6 〜 #15)

| PR | Step | 内容 |
|---:|---:|---|
| #6 | 1 | Web プラットフォーム抽象化 (lib/core/platform/) |
| #7 | 2 | License 管理 (free/pro/enterprise + 機能フラグ 18 個) |
| #8 | 3 | Feedback (mailto + 端末情報自動添付) |
| #9 | 4 | Settings page (バックアップ/フィードバック/プライバシー/OSS ライセンス) |
| #10 | 5 | Tree モデル拡張 + DB マイグレーション v3→v5 (Plot テーブル含む) |
| #11 | 6 | TreeInputDialog / TreeDetailsDialog (タブ UI、16 フィールド) |
| #12 | 7 | Map page refactor、summary_dashboard 簡素化 |
| #13 | 8 | Plot management (CRUD、PlotListPage / PlotDetailPage) |
| #14 | 9 | Statistics reports (作業エリア別 / 林班別 / 間伐シミュ) |
| #15 | 10 | PDF 生成 (調査野帳 / 材積レポート / 写真台帳) |

### 後始末 / 品質改善 (PRs #16 〜 #25)

| PR | 内容 |
|---:|---|
| #16 | WorkAreaList カードに ⋮ メニュー → Plot / Statistics / PDF へ配線 |
| #17 | Deprecated API 一括対応 (Share / Table.fromTextArray / withOpacity / FormField.value / RadioGroup) |
| #18 | dart:html → package:web 移行 |
| #19 | .gitignore に Flutter ルール追加、.dart_tool/ untrack |
| #20 | **Drift schema migration test (v3→v5 自動検証、3 ケース pass)** |
| #21 | map_page に Plot 描画 + 「プロット追加」FAB |
| #22 | TreeInputDialog で ImageSourceWidget 使用 (Web 安全化) |
| #23 | PDF 保存を FileSaver 経由に (Web 安全化) |
| #24 | Map UI レイヤー残存 `dart:io` 一掃 |
| #25 | **PDF 写真台帳に実画像埋め込み (FileReader 抽象追加)** |

### ドキュメント / インフラ (PRs #26 〜)

| PR | 内容 |
|---:|---|
| #26 | `plan.md` 追加 + `README.md` 全面更新、`instruction2.md` 廃止 |
| #27 | **Supabase 新プロジェクト (`iorzhydjarafdwvopjtc`) への移行 + GitHub Actions Keepalive ワークフロー** |
| #28 | summary_dashboard の軽微 overflow 修正 + plan.md リフレッシュ |
| #29 | Claude Code on the web 用 SessionStart hook（Flutter SDK 3.38.4 自動インストール + `pub get`） |
| – | **月次 Supabase バックアップ workflow `.github/workflows/supabase-backup.yml`**（roles/schema/data の SQL ダンプ → Artifact + Release 保存） |

### 検証状況

- ✅ `flutter analyze`: 0 errors, ~31 issues (info のみ、既存 unused field 系)
- ✅ `flutter test test/migration_test.dart`: All 3 tests passed
- ✅ **Supabase 同期実機検証** (2026-05-26): auth.users / public.work_areas / public.trees / Storage photos すべて同期確認済み
- 🟡 実機 UI スモークテスト: 主要機能完了、Phase 3 拡張機能 (Plot/Statistics/PDF) は追加確認推奨
- ❌ Flutter Web ビルド: 未検証（バックエンド層 export/sync/backup に dart:io が残存）

---

## 7. 現在の主要課題と判断ポイント

### 7.1 ✅ Supabase プロジェクト復活 (完了 2026-05-26)

**経緯**:
- 旧プロジェクト `wyjyaydbchukvptlhcny` が 90 日以上 pause → 復元不可
- backup を調査したところ `public` スキーマに forest-app の主要テーブル (`work_areas`/`trees`) が無く、`survey_points` 単独 → **クライアントは一度も Supabase 同期できていなかった** ことが判明
- 失うデータなしと判断、新プロジェクトに **クリーン状態で再構築**

**実施内容** (PR #27 マージ):
- 新プロジェクト `iorzhydjarafdwvopjtc` を作成 (Tokyo region, Free tier)
- PostGIS 拡張有効化、`public.work_areas` / `public.trees` テーブル + RLS ポリシー (`auth.uid() = user_id`) 作成
- Storage バケット `photos` (Public) + RLS ポリシー作成
- クライアント `lib/main.dart` の URL/anonKey を新プロジェクトに差し替え
- Authentication → Providers → Email の **Confirm email を OFF** (rate limit 回避 + 即時アクティベート)
- `.github/workflows/supabase-keepalive.yml` を追加（6 日ごとに REST API ping、cron + 手動実行可）

**動作確認結果** (2026-05-26 実機):
- ✅ サインアップ → `auth.users` に user 1 件 (i007955@gmail.com)
- ✅ 作業エリア作成 → `public.work_areas` に row 同期
- ✅ 樹木追加 (TreeInputDialog) → `public.trees` に 2 件同期 (sugi, sugi2)
- ✅ 写真添付 → Storage `photos` バケットに upload (63KB jpg)

**残り運用設定** (ユーザー作業):
- [ ] GitHub Secrets に `SUPABASE_URL` / `SUPABASE_ANON_KEY` を登録
- [ ] Actions タブから Keepalive workflow を手動実行 → 緑になることを確認

### 7.2 ✅ 実機 UI スモークテスト (主要機能完了 2026-05-26)

**確認済み** (実機エミュレータ Android 16 で確認):
- ✅ アプリ起動 → クラッシュなし
- ✅ 新規サインアップ → Supabase Auth 連携 OK
- ✅ 作業エリア作成 → 一覧表示
- ✅ 樹木追加 (TreeInputDialog で species/height/diameter/health_status 入力)
- ✅ 写真撮影 → Supabase Storage 同期
- ✅ summary_dashboard 表示 (※ 軽微 overflow バグあり → PR #28 で修正)

**追加で確認推奨** (本人で時間がある時に):
- [ ] WorkAreaList の ⋮ メニュー (Plot 一覧 / Statistics / PDF 出力) 各起動
- [ ] 地図画面 FAB「プロット追加」→ 円形/方形描画
- [ ] 統計レポート 4 タブ表示
- [ ] PDF 出力 → 共有シート → 実写真が埋め込まれている
- [ ] GPS トラック記録 / フォトギャラリー (回帰確認)
- [ ] TreeInputDialog の Phase 3 拡張フィールド (volume/age/forestSection/vigor 等) の入力経路

### 7.3 🟢 バックエンド層 `dart:io` 残存（Web 完全対応の前提）

| ファイル | 用途 | 対応規模 |
|---|---|---|
| `export_service.dart` | CSV/GPX export | 中 (FileSaver 経由化、テンプレ確認) |
| `sync_repository.dart` | 写真 upload | 中 (XFile.bytes 経由化) |
| `backup_service.dart` | ローカルバックアップファイル操作 | 大 (Web 概念再設計) |

リリース blocker ではなく、Flutter Web ビルドを通したい時の前提条件。

### 7.4 🟢 PDF / Statistics 内容のドメイン検証

- 材積式 `V = 0.000045 × D² × H` は **スギ/ヒノキ/マツ向け二変数式**。樹種別に係数を変えるべきかは林業実務家にレビュー依頼推奨。
- 樹勢評価 A/B/C は **林野庁の標準基準と整合確認** が望ましい。
- 蓄積量 `m³/ha` と立木密度 `本/ha` の計算式の妥当性。
- 間伐シミュレーションは現状サンプル値、本格化は次フェーズ。

### 7.5 🟢 UI ナビゲーション網羅性

- Settings page から License 表示への配線が未整備（PR #9 で取り込んだが UI から License 状態確認が不可）
- Phase 3 機能群の onboarding / ヘルプテキストが不足

---

## 8. 将来計画 (Rough Roadmap)

### v1.3 (直近、Phase 3 リリース)

**ゴール**: 既存 v1.2 ユーザーが Phase 3 機能を享受できる状態。

- [x] Phase 3 機能群を main にマージ
- [x] DB migration v3→v5 自動検証
- [x] PDF 写真埋め込み
- [ ] **Supabase 復旧（または方針確定）** ← release blocker
- [ ] 実機 UI スモークテスト合格
- [ ] Google Play リリース （バージョン 1.3.0+3）

### v1.4 (中期、品質向上)

- [ ] Settings UI から License 状態表示・アップグレード
- [ ] 間伐シミュレーションの本格化（樹勢 / 直径分布 / 面積比から実数値）
- [ ] 同期競合解決フロー (現状は単純フラグのみ)
- [ ] 多言語化 (intl + arb、日本語 / 英語)
- [ ] スプラッシュ / オンボーディング画面
- [ ] バックエンド層の Web 安全化 (export/sync/backup)

### v2.0 (長期、Web 展開)

- [ ] **Flutter Web ビルド対応** (バックエンド層 dart:io 除去後)
- [ ] Web 管理画面 (組織向け、PostGIS の SQL 直接活用)
- [ ] AI 材積推定 (写真 → 直径推定)
- [ ] 3D 地形オーバーレイ
- [ ] iOS 対応 (Apple Developer Program $99/年 必要)

---

## 9. Claude からの意見・アドバイス

> プロジェクトの方向性は健全だと判断します。ただし以下の論点は意識しておくことを推奨します。

### 9.1 Supabase Free Tier の構造的リスク 🟡 (対応中)

**経緯**: 90 日 pause → 復元不可は、今回まさに直面した問題でした。

**実施済み対策** (PR #27、2026-05-26):
- ✅ 新プロジェクト `iorzhydjarafdwvopjtc` で再構築
- ✅ GitHub Actions `.github/workflows/supabase-keepalive.yml` を追加（6 日ごとに REST API ping）
- ⏸ GitHub Secrets 登録 + 疎通確認は **ユーザー作業待ち**

**実施済み対策** (2026-06-18):
- ✅ **月次バックアップ workflow `.github/workflows/supabase-backup.yml` を追加**（毎月 1 日に Supabase CLI で roles/schema/data を SQL ダンプ → ワークフロー Artifact 90 日 + GitHub Release 恒久保存。手動実行可）。データ消失（誤操作/インシデント）に備える
- ⏸ 新規 Secret `SUPABASE_DB_URL`（Session pooler 接続文字列）の登録 + 手動実行での疎通確認は **ユーザー作業待ち**

**残る論点**:
- **Storage / auth のバックアップ**: SQL ダンプは public スキーマ（work_areas/trees 等）が対象。Storage の写真ファイルと `auth.users` は別系統のため、必要になれば別途バックアップ手段を検討
- **Pro Tier 切替の目安**: 月 $25 の Pro Tier なら inactivity 制約なし、Storage 100GB、daily backups。「ユーザーが他者にも広がる時点」または「ストレージが 500MB 超え」 で切替を検討

**Claude 案**: keepalive（pause 防止）+ 月次 SQL ダンプ（データ保全）で当面の Free Tier リスクはカバー済み。次の懸念は Storage 写真の保全だが、現状データ量では優先度低。

### 9.2 「オフライン → クラウドはオプション」を UX に明示すべき 🟡

現状は起動時にログイン画面が出る設計の可能性が高いですが、**「ログインしなくても使える」を onboarding で明示**することを推奨します。理由：

- そもそも山に入ると圏外なので「サインアップ → 認証メール」フローは現場で詰む
- 林業 NPO / 学生など、共同編集が不要なユーザーには認証が逆に障壁
- ローカル完結で十分価値があるアプリ

**改修案**: 「とりあえず使う（ローカルのみ）」/ 「同期する（ログイン）」の二択を初回起動で提示。後からアカウント作成にも進める。

### 9.3 林業ドメイン要件の早期検証 🟡

Tree モデル拡張で追加した 11 フィールド（材積/樹齢/林班/小班/立木番号/樹勢/病虫害/傾斜/方位/備考/間伐対象）は、林業現場でよく使われる項目を網羅しているように見えますが、**現場のヒアリングが入っていない** 可能性があります。

- **林業従事者 1〜2 名 のレビュー** を早めに（できれば v1.3 リリース前に）
- 「材積式の係数」「樹勢評価基準」が地域 / 樹種でブレないか
- 「林班 / 小班」のラベル UX が森林簿と整合するか（自治体ごとの命名規則差）

**Claude の所感**: GPT セッションで設計された UI は標準的に見えるが、**実務家のレビューが入って初めて「使える」になる**。

### 9.4 i18n の早期導入 🟢

現状ハードコードされた日本語は数百カ所。後から arb 化は地獄なので、**v1.4 のタイミングで intl 化** を強く推奨します。並行で英語化を進めれば、海外林業（東南アジア / 南米）市場も視野に。

### 9.5 PDF の品質 🟢

PDF 出力は実装上重要な差別化機能ですが、**フォント問題** に注意：

- 現状の `pdf` パッケージは **日本語フォントを明示指定しないと豆腐になる** ことがある
- カスタムフォント（Noto Sans JP 等）を assets に追加して `pw.ThemeData.withFont(...)` で読み込ませる対応を要検証
- A4 縦印刷時のレイアウト崩れも実機で確認

### 9.6 セキュリティ / プライバシーの整合性 🟢

- 写真は端末ローカル + Supabase Storage の二段持ち。**Supabase Storage の RLS（Row Level Security）が正しく設定されているか** 要確認（誰でも他人の写真にアクセスできない）
- 位置情報を扱う以上、`docs/privacy_policy.md` の宣言と実装の整合性を再確認
- v1.3 リリース時に privacy_policy.md の最終更新日を更新

### 9.7 テスタビリティ 🟢

現状の自動テストは migration test のみ。リリース blocker ではないが、**主要 widget の golden test** が将来あると、Phase 4 以降の refactor の安全性が大幅に上がります。優先度は低め。

---

## 10. 運用ルール

### 10.1 PR フロー

- ブランチ命名: `feat/<name>`, `chore/<name>`, `test/<name>`, `docs/<name>`, `hotfix/<name>`
- コミット規約: 簡易 Conventional Commit (`feat: ...`, `chore(scope): ...`, `test: ...`)
- 各 PR で必須:
  - `flutter analyze` 0 errors
  - migration test pass (DB スキーマ変更時)
  - PR 本文に「変更内容 / 検証 / Test plan / 既知の制約 / 次のフォローアップ」

### 10.2 スキーマ変更時の手順

```bash
# 1. lib/core/database/app_database.dart の schemaVersion をバンプ、onUpgrade 追加
# 2. build_runner で .g.dart 再生成
dart run build_runner build --delete-conflicting-outputs
# 3. drift_schemas に新バージョンを dump
dart run drift_dev schema dump lib/core/database/app_database.dart drift_schemas/
# 4. migration test 用ヘルパー再生成
dart run drift_dev schema generate drift_schemas/ test/generated_migrations/
# 5. test/migration_test.dart に新バージョン用のテストケース追加
flutter test test/migration_test.dart
```

### 10.3 ドキュメント更新

- 大きな PR がマージされたら `plan.md` の Section 6 (進捗) を 1〜2 行追記
- リリース時に `plan.md` の Section 8 (ロードマップ) を見直し
- 月 1 回程度、Section 7 (現在の課題) を棚卸し

### 10.4 メモリ（AI 用の文脈）

開発者の AI セッションは `~/.claude/projects/.../memory/` 配下に蓄積されています。新しい AI セッションを始めるときはこのファイル (`plan.md`) と memory を参照させることで、毎回ゼロから説明する手間を省けます。

---

## 11. 参考: 関連ドキュメント

| ファイル | 内容 |
|---|---|
| `README.md` | 公開リードミー（プロダクト紹介、セットアップ） |
| `plan.md` | **本ファイル**（開発計画俯瞰用） |
| `docs/privacy_policy.md` | プライバシーポリシー |
| `docs/store_listing.md` | Google Play ストア掲載情報 |
| `test/migration_test.dart` | DB マイグレーション自動検証 |
| `drift_schemas/drift_schema_vN.json` | スキーマ snapshot (バージョン毎) |

旧 `instruction2.md` の内容（初期の技術スタック宣言）は本ファイル Section 2-3 に統合済みのため、`instruction2.md` は削除しました。
