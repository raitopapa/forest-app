// lib/core/platform/file_reader_stub.dart
//
// FileReader のインターフェース定義（ダミー実装）。
// 実際の処理は file_reader_io.dart / file_reader_web.dart が担う。

import 'dart:typed_data';

class FileReader {
  /// ローカルファイルパスからバイト列を読み込む。
  ///
  /// - [path]: ローカルファイルパス。
  ///
  /// 戻り値: 読み込み成功なら Uint8List、失敗 / 未対応プラットフォーム / ファイル
  /// 不在の場合は null。例外は内部で握りつぶす (呼び出し側で null 判定する設計)。
  static Future<Uint8List?> readBytes(String path) async => null;
}
