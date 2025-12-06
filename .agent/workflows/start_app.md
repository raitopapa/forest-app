---
description: 森林管理アプリの起動（バックエンド + フロントエンド）
---

# 森林管理アプリの起動

このワークフローは、Python FastAPIバックエンドとReact Nativeフロントエンドの両方を起動します。

## 1. バックエンドサーバーの起動

新しいターミナルを開き、以下を実行します：

```powershell
# プロジェクトルートへ移動
cd c:\Users\i0079\forest-app\forest-app

# 依存関係がインストールされていることを確認: pip install -r backend/requirements.txt

# FastAPIサーバーを起動
python -m uvicorn backend.server:app --reload --port 8001
```

APIは `http://localhost:8001` で利用可能になります。
Swagger UI: `http://localhost:8001/docs`

## 2. React Nativeアプリの起動

**別の**ターミナルを開き、以下を実行します：

```powershell
# プロジェクトルートへ移動
cd c:\Users\i0079\forest-app\forest-app

# Metro BundlerとAndroidエミュレータを起動
npm run android
```

Metro Bundlerのみを起動したい場合：
```powershell
npm start
```
その後、`a` を押してAndroidで実行します。

## トラブルシューティング

- **バックエンド接続失敗**: バックエンドがポート8001で実行されていることを確認してください。
- **エミュレータの問題**: Android Virtual Device (AVD) が実行されているか、USB経由で接続されていることを確認してください。
