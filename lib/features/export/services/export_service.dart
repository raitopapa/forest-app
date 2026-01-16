import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../map/data/tree_repository.dart';
import '../../map/data/map_object_repository.dart';
import '../../map/domain/models/map_object.dart';

final exportServiceProvider = Provider((ref) => ExportService(
      ref.read(treeRepositoryProvider),
      ref.read(mapObjectRepositoryProvider),
    ));

/// Export format options.
enum ExportFormat { csv, gpx, jpeg, all }

class ExportService {
  final TreeRepository _treeRepo;
  final MapObjectRepository _mapObjectRepo;

  ExportService(this._treeRepo, this._mapObjectRepo);

  /// Export data with format selection.
  Future<List<XFile>> exportData(
    String workAreaId, {
    ExportFormat format = ExportFormat.all,
    GlobalKey? mapKey, // Required for JPEG export
  }) async {
    final trees = await _treeRepo.getTrees(workAreaId);
    final mapObjects = await _mapObjectRepo.getMapObjects(workAreaId);
    
    final directory = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    
    final filesToShare = <XFile>[];

    // 1. Export CSV (Trees + MapObjects)
    if (format == ExportFormat.csv || format == ExportFormat.all) {
      final csvFile = await _exportCsv(trees, mapObjects, directory, timestamp);
      if (csvFile != null) filesToShare.add(csvFile);
    }

    // 2. Export GPX (All Geometry)
    if (format == ExportFormat.gpx || format == ExportFormat.all) {
      final gpxFile = await _exportGpx(trees, mapObjects, directory, timestamp);
      filesToShare.add(gpxFile);
    }

    // 3. Export JPEG (Map Screenshot)
    if ((format == ExportFormat.jpeg || format == ExportFormat.all) && mapKey != null) {
      final jpegFile = await _exportMapScreenshot(mapKey, directory, timestamp);
      if (jpegFile != null) filesToShare.add(jpegFile);
    }

    // Share Files
    if (filesToShare.isNotEmpty) {
      await Share.shareXFiles(filesToShare, text: 'Forest App Data Export');
    }

    return filesToShare;
  }

  /// Export trees and map objects to CSV.
  Future<XFile?> _exportCsv(
    List<Map<String, dynamic>> trees,
    List<MapObject> mapObjects,
    Directory directory,
    int timestamp,
  ) async {
    final rows = <List<dynamic>>[];
    
    // Header
    rows.add(['Type', 'ID', 'Name/Species', 'Description', 'Height', 'Diameter', 'Latitude', 'Longitude', 'Attributes']);

    // Trees
    for (var t in trees) {
      final wkt = t['location'] as String;
      final coords = wkt.substring(6, wkt.length - 1).split(' ');
      rows.add([
        'Tree',
        t['id'],
        t['species'],
        t['health_status'] ?? '',
        t['height'],
        t['diameter'],
        coords[1],
        coords[0],
        '',
      ]);
    }

    // MapObjects
    for (var obj in mapObjects) {
      String lat = '', lng = '';
      if (obj.type == MapObjectType.point) {
        final coords = obj.geometry.substring(6, obj.geometry.length - 1).split(' ');
        lat = coords[1];
        lng = coords[0];
      }
      rows.add([
        obj.type.name,
        obj.id,
        obj.name ?? '',
        obj.description ?? '',
        '',
        '',
        lat,
        lng,
        obj.attributes?.toString() ?? '',
      ]);
    }

    if (rows.length <= 1) return null; // Only header

    final csvFile = File('${directory.path}/forest_data_$timestamp.csv');
    final csvString = const ListToCsvConverter().convert(rows);
    await csvFile.writeAsString(csvString);
    return XFile(csvFile.path);
  }

  /// Export to GPX format.
  Future<XFile> _exportGpx(
    List<Map<String, dynamic>> trees,
    List<MapObject> mapObjects,
    Directory directory,
    int timestamp,
  ) async {
    final gpxFile = File('${directory.path}/forest_data_$timestamp.gpx');
    final gpxBuffer = StringBuffer();
    gpxBuffer.writeln('<?xml version="1.0" encoding="UTF-8"?>');
    gpxBuffer.writeln('<gpx version="1.1" creator="ForestApp" xmlns="http://www.topografix.com/GPX/1/1">');
    
    // Trees as Waypoints
    for (var t in trees) {
      final wkt = t['location'] as String;
      final coords = wkt.substring(6, wkt.length - 1).split(' ');
      gpxBuffer.writeln('<wpt lat="${coords[1]}" lon="${coords[0]}">');
      gpxBuffer.writeln('  <name>${_escapeXml(t['species'] ?? 'Tree')}</name>');
      gpxBuffer.writeln('  <desc>Height: ${t['height']}m, Diameter: ${t['diameter']}cm</desc>');
      gpxBuffer.writeln('</wpt>');
    }

    // MapObjects (Points) as Waypoints
    for (var obj in mapObjects.where((o) => o.type == MapObjectType.point)) {
      final coords = obj.geometry.substring(6, obj.geometry.length - 1).split(' ');
      gpxBuffer.writeln('<wpt lat="${coords[1]}" lon="${coords[0]}">');
      gpxBuffer.writeln('  <name>${_escapeXml(obj.name ?? "Point")}</name>');
      gpxBuffer.writeln('  <desc>${_escapeXml(obj.description ?? "")}</desc>');
      gpxBuffer.writeln('</wpt>');
    }

    // MapObjects (Lines) as Tracks
    for (var obj in mapObjects.where((o) => o.type == MapObjectType.line)) {
      gpxBuffer.writeln('<trk>');
      gpxBuffer.writeln('  <name>${_escapeXml(obj.name ?? "Track")}</name>');
      gpxBuffer.writeln('  <trkseg>');
      final coordsStr = obj.geometry.substring(11, obj.geometry.length - 1);
      final points = coordsStr.split(',');
      for (var p in points) {
        final xy = p.trim().split(' ');
        gpxBuffer.writeln('    <trkpt lat="${xy[1]}" lon="${xy[0]}"></trkpt>');
      }
      gpxBuffer.writeln('  </trkseg>');
      gpxBuffer.writeln('</trk>');
    }

    // MapObjects (Polygons) as Routes
    for (var obj in mapObjects.where((o) => o.type == MapObjectType.polygon)) {
      gpxBuffer.writeln('<rte>');
      gpxBuffer.writeln('  <name>${_escapeXml(obj.name ?? "Area")}</name>');
      final coordsStr = obj.geometry.substring(9, obj.geometry.length - 2); // POLYGON((...))
      final points = coordsStr.split(',');
      for (var p in points) {
        final xy = p.trim().split(' ');
        gpxBuffer.writeln('  <rtept lat="${xy[1]}" lon="${xy[0]}"></rtept>');
      }
      gpxBuffer.writeln('</rte>');
    }
    
    gpxBuffer.writeln('</gpx>');
    await gpxFile.writeAsString(gpxBuffer.toString());
    return XFile(gpxFile.path);
  }

  /// Capture map screenshot and save as JPEG.
  Future<XFile?> _exportMapScreenshot(
    GlobalKey mapKey,
    Directory directory,
    int timestamp,
  ) async {
    try {
      final boundary = mapKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return null;

      final pngBytes = byteData.buffer.asUint8List();
      final file = File('${directory.path}/map_screenshot_$timestamp.png');
      await file.writeAsBytes(pngBytes);

      return XFile(file.path);
    } catch (e) {
      print('Screenshot export failed: $e');
      return null;
    }
  }

  /// Escape special XML characters.
  String _escapeXml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }
}

/// Show export options dialog.
Future<ExportFormat?> showExportDialog(BuildContext context) async {
  return showDialog<ExportFormat>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('エクスポート形式'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.table_chart, color: Colors.green),
            title: const Text('CSV'),
            subtitle: const Text('属性データをスプレッドシート形式で'),
            onTap: () => Navigator.pop(context, ExportFormat.csv),
          ),
          ListTile(
            leading: const Icon(Icons.route, color: Colors.blue),
            title: const Text('GPX'),
            subtitle: const Text('GPS機器やGISソフト向け'),
            onTap: () => Navigator.pop(context, ExportFormat.gpx),
          ),
          ListTile(
            leading: const Icon(Icons.image, color: Colors.orange),
            title: const Text('地図画像'),
            subtitle: const Text('現在の地図をPNGで保存'),
            onTap: () => Navigator.pop(context, ExportFormat.jpeg),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.folder_zip, color: Colors.purple),
            title: const Text('すべてエクスポート'),
            subtitle: const Text('CSV + GPX + 画像'),
            onTap: () => Navigator.pop(context, ExportFormat.all),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('キャンセル'),
        ),
      ],
    ),
  );
}

