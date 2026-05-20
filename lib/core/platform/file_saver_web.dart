// lib/core/platform/file_saver_web.dart
//
// Flutter Web 向け実装 (package:web + dart:js_interop)。
// Blob を生成して anchor クリックで download 属性を発火し、
// ブラウザのダウンロードダイアログを出す。

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

class FileSaver {
  static Future<bool> save({
    required String filename,
    required Uint8List bytes,
    String mimeType = 'application/octet-stream',
  }) async {
    try {
      final blob = web.Blob(
        <JSAny>[bytes.toJS].toJS,
        web.BlobPropertyBag(type: mimeType),
      );
      final url = web.URL.createObjectURL(blob);

      final anchor = web.HTMLAnchorElement()
        ..href = url
        ..download = filename
        ..style.display = 'none';

      web.document.body?.appendChild(anchor);
      anchor.click();
      anchor.remove();

      // 次の tick で revoke（すぐ revoke すると一部ブラウザで失敗する）
      Future.delayed(const Duration(seconds: 1), () {
        web.URL.revokeObjectURL(url);
      });

      return true;
    } catch (e, st) {
      // ignore: avoid_print
      print('FileSaver.save (web) failed: $e\n$st');
      return false;
    }
  }
}
