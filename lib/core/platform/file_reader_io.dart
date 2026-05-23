// lib/core/platform/file_reader_io.dart
//
// モバイル (Android / iOS) および Desktop 向け実装。

import 'dart:io';
import 'dart:typed_data';

class FileReader {
  static Future<Uint8List?> readBytes(String path) async {
    try {
      final file = File(path);
      if (!await file.exists()) return null;
      return await file.readAsBytes();
    } catch (_) {
      return null;
    }
  }
}
