// lib/core/platform/file_saver_stub.dart
//
// FileSaver のインターフェース定義（ダミー実装）。
// 実際の処理は file_saver_io.dart / file_saver_web.dart が担う。
//
// この stub は、どちらの dart:io / dart:html も利用できない環境
// （AOT コンパイル時の解析など）で参照されるためのフォールバック。

import 'dart:typed_data';

class FileSaver {
  /// ファイルを保存する。
  ///
  /// - [filename]: 保存時のファイル名（拡張子込み）。例: "trees.csv"
  /// - [bytes]: 保存するバイト列。
  /// - [mimeType]: MIME タイプ（Web では必須）。例: "text/csv"
  /// - [subject]: モバイル共有シートで使われる件名 (Web では無視)。
  /// - [text]: モバイル共有シートで使われる本文 (Web では無視)。
  ///
  /// 戻り値は保存に成功した場合 true。
  static Future<bool> save({
    required String filename,
    required Uint8List bytes,
    String mimeType = 'application/octet-stream',
    String? subject,
    String? text,
  }) async {
    throw UnsupportedError(
      'FileSaver は dart:io または dart:html のいずれかが必要です。'
      'プラットフォームに応じた実装が import されているか確認してください。',
    );
  }
}
