// lib/core/platform/file_saver_web.dart
//
// Flutter Web 向け実装。
// Blob を生成して anchor クリックで download 属性を発火し、
// ブラウザのダウンロードダイアログを出す。

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:typed_data';

class FileSaver {
  static Future<bool> save({
    required String filename,
    required Uint8List bytes,
    String mimeType = 'application/octet-stream',
  }) async {
    try {
      final blob = html.Blob([bytes], mimeType);
      final url = html.Url.createObjectUrlFromBlob(blob);

      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', filename)
        ..style.display = 'none';

      html.document.body?.children.add(anchor);
      anchor.click();
      anchor.remove();

      // 次の tick で revoke（すぐ revoke すると一部ブラウザで失敗する）
      Future.delayed(const Duration(seconds: 1), () {
        html.Url.revokeObjectUrl(url);
      });

      return true;
    } catch (e, st) {
      print('FileSaver.save (web) failed: $e\n$st');
      return false;
    }
  }
}

// --------- 将来的な package:web 版への移行メモ ---------
//
// Flutter 3.22+ では dart:html の代わりに package:web と dart:js_interop を
// 使うのが推奨。新しい書き方は概ね以下：
//
// import 'package:web/web.dart' as web;
// import 'dart:js_interop';
//
// final blob = web.Blob(
//   [bytes.toJS].toJS,
//   web.BlobPropertyBag(type: mimeType),
// );
// final url = web.URL.createObjectURL(blob);
// ...
//
// 当面は dart:html でも動作するため、移行は余裕があるときでよい。
