import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    // 新 Supabase プロジェクト (2026-05-24 移行)
    // 旧 wyjyaydbchukvptlhcny は 90 日 inactive pause で復元不可だったため
    // クリーン状態で再構築 (work_areas / trees テーブル + photos バケット + RLS)
    // 再発防止: .github/workflows/supabase-keepalive.yml で 6 日ごとに ping
    url: 'https://iorzhydjarafdwvopjtc.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlvcnpoeWRqYXJhZmR3dm9wanRjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzk1NTAyNjcsImV4cCI6MjA5NTEyNjI2N30.zjBFmjZkqaMn-J6JoMYYYOKzo00LALyLdltwXqgwyXw',
  );

  runApp(
    const ProviderScope(
      child: ForestApp(),
    ),
  );
}
