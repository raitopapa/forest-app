// lib/core/platform/image_source.dart
//
// 画像表示のクロスプラットフォーム抽象。
//
// - モバイル: ローカルファイルパス（photoPath）があれば Image.file
// - Web: ファイルパスは使えないため、Uint8List の bytes か URL で表示
// - フォールバック: 同期済みの URL（photoUrl）で Image.network
//
// 既存 photo_gallery_page.dart / tree_details_dialog.dart の
// File.existsSync() チェックを置き換えるためのもの。

import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

// dart:io は Web でエラーになるので conditional import にする手もあるが、
// Image.file は kIsWeb 判定で呼ばないようにすれば現状は動く。
import 'dart:io' as io;

class ImageSourceWidget extends StatelessWidget {
  /// ローカルパス。モバイル環境のみで利用。
  final String? path;

  /// 同期済みの Supabase Storage URL。
  final String? url;

  /// Web 等でメモリ上に保持している画像バイト。
  final Uint8List? bytes;

  /// 表示サイズ。
  final double? width;
  final double? height;
  final BoxFit fit;

  /// プレースホルダ。
  final Widget? placeholder;

  const ImageSourceWidget({
    super.key,
    this.path,
    this.url,
    this.bytes,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    // 優先順位: bytes（最新）> ローカルパス（モバイルのみ）> URL > プレースホルダ

    if (bytes != null && bytes!.isNotEmpty) {
      return Image.memory(
        bytes!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    if (!kIsWeb && path != null && path!.isNotEmpty) {
      final file = io.File(path!);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (_, __, ___) => _placeholder(),
        );
      }
    }

    if (url != null && url!.isNotEmpty) {
      return Image.network(
        url!,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
        loadingBuilder: (ctx, child, progress) {
          if (progress == null) return child;
          return _loadingIndicator();
        },
      );
    }

    return _placeholder();
  }

  Widget _placeholder() {
    if (placeholder != null) return placeholder!;
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade200,
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Colors.grey.shade400,
        size: 32,
      ),
    );
  }

  Widget _loadingIndicator() {
    return Container(
      width: width,
      height: height,
      color: Colors.grey.shade100,
      alignment: Alignment.center,
      child: const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }
}

/// 画像ピッカーから取得した XFile を正規化するヘルパー。
///
/// モバイル：XFile.path をそのまま DB に保存可能（ローカル参照）。
/// Web：XFile.path はブラウザ内の blob URL で、再起動で無効化されるため、
///      bytes を Supabase Storage 等にアップロードし、公開 URL のみ DB に保存する。
class PickedImage {
  /// モバイル用: ローカルファイルパス（Web では null）。
  final String? path;

  /// バイト列（Web で必須、モバイルでも利用可）。
  final Uint8List bytes;

  /// 元ファイル名。
  final String name;

  /// MIME タイプ（判定できなければ null）。
  final String? mimeType;

  PickedImage({
    this.path,
    required this.bytes,
    required this.name,
    this.mimeType,
  });
}
