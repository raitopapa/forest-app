// lib/core/platform/file_reader_web.dart
//
// Flutter Web 向け実装。
// Web ではローカルファイルパスから bytes を直接読む手段がない (XFile.path は
// blob URL で再起動後に無効化されるため)。常に null を返す。
//
// Web で画像 bytes を扱いたい場合は、core/platform/image_source.PickedImage の
// bytes プロパティ経由でメモリ上に保持するのが正しい。

import 'dart:typed_data';

class FileReader {
  static Future<Uint8List?> readBytes(String path) async => null;
}
