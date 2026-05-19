// lib/core/platform/file_saver.dart
//
// プラットフォームに応じて適切な実装を import する。
//
// - モバイル / デスクトップ: dart:io を使い File に書き出して Share。
// - Web: Blob を生成してブラウザダウンロードを発火。
//
// 呼び出し側はこの 1 ファイルだけを import すれば、OS 差を意識せず使える。

export 'file_saver_stub.dart'
    if (dart.library.io) 'file_saver_io.dart'
    if (dart.library.html) 'file_saver_web.dart';
