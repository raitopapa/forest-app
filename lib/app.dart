import 'package:flutter/material.dart';
import 'features/map/presentation/map_page.dart';

class ForestApp extends StatelessWidget {
  const ForestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Forest Management GIS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MapPage(),
    );
  }
}
