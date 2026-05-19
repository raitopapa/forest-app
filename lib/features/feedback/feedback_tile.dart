import 'package:flutter/material.dart';

import 'feedback_service.dart';

/// 設定画面などに埋め込むためのフィードバック送信タイル。
///
/// 使い方:
/// ```dart
/// ListView(children: const [
///   ...
///   FeedbackTile(),
/// ])
/// ```
class FeedbackTile extends StatelessWidget {
  const FeedbackTile({super.key, this.service = const FeedbackService()});

  final FeedbackService service;

  Future<void> _onTap(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final ok = await service.sendFeedback();
      if (!ok) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('メーラーを起動できませんでした。お手数ですが '
                '$feedbackEmail まで直接ご連絡ください。'),
          ),
        );
      }
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('フィードバック画面を開けませんでした: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.feedback_outlined),
      title: const Text('フィードバック・お問い合わせ'),
      subtitle: const Text('不具合報告やご要望をお送りください（端末情報が自動添付されます）'),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => _onTap(context),
    );
  }
}
