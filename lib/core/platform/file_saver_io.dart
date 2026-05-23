// lib/core/platform/file_saver_io.dart
//
// モバイル (Android / iOS) および Desktop 向け実装。
// getTemporaryDirectory に保存したうえで share_plus で共有する。

import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class FileSaver {
  static Future<bool> save({
    required String filename,
    required Uint8List bytes,
    String mimeType = 'application/octet-stream',
    String? subject,
    String? text,
  }) async {
    try {
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/$filename');
      await file.writeAsBytes(bytes);

      // 共有シート経由でユーザーが「写真に保存」「Drive に保存」「LINE で送る」等を選べる
      await SharePlus.instance.share(ShareParams(
        files: [XFile(file.path, mimeType: mimeType)],
        subject: subject ?? filename,
        text: text,
      ));
      return true;
    } catch (e, st) {
      // ignore: avoid_print
      print('FileSaver.save failed: $e\n$st');
      return false;
    }
  }
}
