import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://wyjyaydbchukvptlhcny.supabase.co',
    anonKey: 'sb_publishable_smJpD_Febbex6fV9SO37Zw_0EYZtPxB',
  );

  runApp(
    const ProviderScope(
      child: ForestApp(),
    ),
  );
}
