// lib/core/platform/file_reader.dart
//
// プラットフォームに応じて適切な実装を import する。
//
// - モバイル / デスクトップ: dart:io で File.readAsBytes
// - Web: null を返す (blob URL の path は再起動で無効化されるため、
//        path から bytes を読む手段がない)
//
// 呼び出し側はこの 1 ファイルだけを import すれば、OS 差を意識せず使える。

export 'file_reader_stub.dart'
    if (dart.library.io) 'file_reader_io.dart'
    if (dart.library.html) 'file_reader_web.dart';
