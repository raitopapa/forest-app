import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../../statistics/domain/models/work_area_statistics.dart';
import '../../plot/domain/models/plot.dart';

final pdfGeneratorServiceProvider = Provider<PdfGeneratorService>((ref) {
  return PdfGeneratorService();
});

class PdfGeneratorService {
  /// 調査野帳PDFを生成
  Future<void> generateFieldNotebook({
    required String workAreaName,
    required List<Map<String, dynamic>> trees,
    required List<Plot> plots,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy年MM月dd日 HH:mm');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // タイトル
          pw.Header(
            level: 0,
            child: pw.Text(
              '森林調査野帳',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 16),

          // 基本情報
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('作業エリア: $workAreaName', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('調査日時: ${dateFormat.format(now)}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('総樹木本数: ${trees.length}本', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('プロット数: ${plots.length}箇所', style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // 樹木リスト
          pw.Text('樹木調査記録', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),

          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
              5: pw.Alignment.centerLeft,
            },
            headers: ['樹種', '樹高(m)', '直径(cm)', '材積(m³)', '樹齢', '備考'],
            data: trees.take(50).map((tree) {
              return [
                tree['species'] ?? '-',
                tree['height']?.toString() ?? '-',
                tree['diameter']?.toString() ?? '-',
                tree['volume'] != null ? (tree['volume'] as double).toStringAsFixed(3) : '-',
                tree['age']?.toString() ?? '-',
                _getTreeNotes(tree),
              ];
            }).toList(),
          ),

          if (trees.length > 50) ...[
            pw.SizedBox(height: 8),
            pw.Text('※ 紙面の都合により最初の50件のみ表示', style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
          ],

          // プロット情報
          if (plots.isNotEmpty) ...[
            pw.SizedBox(height: 24),
            pw.Text('プロット情報', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            ...plots.map((plot) => pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 8),
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(plot.name, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('形状: ${plot.shape.displayName} / 面積: ${plot.area.toStringAsFixed(1)} m²', style: const pw.TextStyle(fontSize: 10)),
                  if (plot.description != null)
                    pw.Text(plot.description!, style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700)),
                ],
              ),
            )),
          ],

          // フッター
          pw.SizedBox(height: 24),
          pw.Divider(),
          pw.Text(
            '森林管理アプリ - 自動生成レポート',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ],
      ),
    );

    await _savePdf(pdf, 'field_notebook_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  /// 材積集計表PDFを生成
  Future<void> generateVolumeReport({
    required String workAreaName,
    required WorkAreaStatistics statistics,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy年MM月dd日');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // タイトル
          pw.Header(
            level: 0,
            child: pw.Text(
              '材積集計表',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 16),

          // 基本情報
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.green50,
              border: pw.Border.all(color: PdfColors.green),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('作業エリア: $workAreaName', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('作成日: ${dateFormat.format(now)}', style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // 全体統計
          pw.Text('全体統計', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey400),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1),
            },
            children: [
              _buildTableRow('総本数', '${statistics.totalTreeCount} 本', isHeader: true),
              _buildTableRow('総材積', '${statistics.totalVolume.toStringAsFixed(2)} m³'),
              _buildTableRow('平均樹高', '${statistics.averageHeight.toStringAsFixed(1)} m'),
              _buildTableRow('平均胸高直径', '${statistics.averageDiameter.toStringAsFixed(1)} cm'),
              if (statistics.averageAge > 0)
                _buildTableRow('平均樹齢', '${statistics.averageAge.toStringAsFixed(0)} 年'),
              if (statistics.plotCount > 0) ...[
                _buildTableRow('プロット数', '${statistics.plotCount} 箇所'),
                _buildTableRow('平均蓄積量', '${statistics.averageStandingVolume.toStringAsFixed(1)} m³/ha'),
                _buildTableRow('平均立木密度', '${statistics.averageTreeDensity.toStringAsFixed(0)} 本/ha'),
              ],
            ],
          ),
          pw.SizedBox(height: 24),

          // 樹種別統計
          pw.Text('樹種別内訳', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 12),
          pw.TableHelper.fromTextArray(
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 10),
            cellStyle: const pw.TextStyle(fontSize: 9),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
            cellHeight: 25,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
              5: pw.Alignment.center,
            },
            headers: ['樹種', '本数', '本数割合', '材積(m³)', '材積割合', '平均樹高(m)'],
            data: statistics.speciesBreakdown.entries.map((entry) {
              final species = entry.value;
              final percentage = species.getPercentage(statistics.totalTreeCount);
              final volumePercentage = species.getVolumePercentage(statistics.totalVolume);
              return [
                species.species,
                '${species.count}本',
                '${percentage.toStringAsFixed(1)}%',
                species.totalVolume.toStringAsFixed(2),
                '${volumePercentage.toStringAsFixed(1)}%',
                species.averageHeight.toStringAsFixed(1),
              ];
            }).toList(),
          ),

          // 間伐情報
          if (statistics.thinningMarkedCount > 0) ...[
            pw.SizedBox(height: 24),
            pw.Text('間伐計画', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.SizedBox(height: 12),
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.orange50,
                border: pw.Border.all(color: PdfColors.orange),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('間伐対象本数: ${statistics.thinningMarkedCount} 本', style: const pw.TextStyle(fontSize: 12)),
                  pw.Text('間伐材積: ${statistics.thinningMarkedVolume.toStringAsFixed(2)} m³', style: const pw.TextStyle(fontSize: 12)),
                  pw.Text('間伐率: ${statistics.thinningRate.toStringAsFixed(1)}%', style: const pw.TextStyle(fontSize: 12)),
                  pw.SizedBox(height: 8),
                  pw.Text('間伐後予測本数: ${statistics.treeCountAfterThinning} 本', style: const pw.TextStyle(fontSize: 12)),
                  pw.Text('間伐後予測材積: ${statistics.volumeAfterThinning.toStringAsFixed(2)} m³', style: const pw.TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],

          // フッター
          pw.SizedBox(height: 24),
          pw.Divider(),
          pw.Text(
            '森林管理アプリ Pro - 自動生成レポート',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ],
      ),
    );

    await _savePdf(pdf, 'volume_report_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  /// 写真台帳PDFを生成
  Future<void> generatePhotoCatalog({
    required String workAreaName,
    required List<Map<String, dynamic>> items,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final dateFormat = DateFormat('yyyy年MM月dd日');

    // 写真付きアイテムのみフィルター
    final itemsWithPhotos = items.where((item) {
      final photoPath = item['photo_path'] as String?;
      return photoPath != null && File(photoPath).existsSync();
    }).toList();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // タイトル
          pw.Header(
            level: 0,
            child: pw.Text(
              '写真台帳',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 16),

          // 基本情報
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey400),
              borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('作業エリア: $workAreaName', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                pw.Text('作成日: ${dateFormat.format(now)}', style: const pw.TextStyle(fontSize: 12)),
                pw.Text('写真点数: ${itemsWithPhotos.length}点', style: const pw.TextStyle(fontSize: 12)),
              ],
            ),
          ),
          pw.SizedBox(height: 24),

          // 写真リスト (2列レイアウト)
          ...List.generate((itemsWithPhotos.length / 2).ceil(), (index) {
            final startIndex = index * 2;
            final endIndex = (startIndex + 2).clamp(0, itemsWithPhotos.length);
            final rowItems = itemsWithPhotos.sublist(startIndex, endIndex);

            return pw.Container(
              margin: const pw.EdgeInsets.only(bottom: 16),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: rowItems.map((item) {
                  return pw.Expanded(
                    child: pw.Container(
                      margin: const pw.EdgeInsets.symmetric(horizontal: 4),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          // 写真 (非同期読み込みのため、実装時は注意)
                          pw.Container(
                            height: 150,
                            decoration: pw.BoxDecoration(
                              border: pw.Border.all(color: PdfColors.grey300),
                            ),
                            child: pw.Center(
                              child: pw.Text('[写真]', style: const pw.TextStyle(color: PdfColors.grey)),
                            ),
                          ),
                          pw.SizedBox(height: 4),
                          // キャプション
                          pw.Text(
                            item['species'] ?? item['name'] ?? '写真${startIndex + rowItems.indexOf(item) + 1}',
                            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
                          ),
                          if (item['description'] != null)
                            pw.Text(
                              item['description'],
                              style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
                              maxLines: 2,
                            ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            );
          }),

          // フッター
          pw.SizedBox(height: 24),
          pw.Divider(),
          pw.Text(
            '森林管理アプリ - 自動生成レポート',
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey),
          ),
        ],
      ),
    );

    await _savePdf(pdf, 'photo_catalog_${DateTime.now().millisecondsSinceEpoch}.pdf');
  }

  /// テーブル行を構築
  pw.TableRow _buildTableRow(String label, String value, {bool isHeader = false}) {
    return pw.TableRow(
      decoration: isHeader ? const pw.BoxDecoration(color: PdfColors.grey200) : null,
      children: [
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ),
        pw.Padding(
          padding: const pw.EdgeInsets.all(8),
          child: pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  /// 樹木の備考欄を生成
  String _getTreeNotes(Map<String, dynamic> tree) {
    final parts = <String>[];

    if (tree['vigor'] != null) {
      parts.add('樹勢:${tree['vigor']}');
    }
    if (tree['marked_for_thinning'] == true) {
      parts.add('間伐対象');
    }
    if (tree['pest_disease'] != null && (tree['pest_disease'] as String).isNotEmpty) {
      parts.add('病虫害');
    }

    return parts.isEmpty ? '-' : parts.join(', ');
  }

  /// PDFを保存して共有
  Future<void> _savePdf(pw.Document pdf, String filename) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$filename');
    await file.writeAsBytes(await pdf.save());

    // 共有
    await SharePlus.instance.share(ShareParams(
      files: [XFile(file.path)],
      subject: 'Forest Management Report',
      text: '森林管理アプリから生成されたレポート',
    ));
  }

  /// プレビュー表示
  Future<void> previewPdf(pw.Document pdf) async {
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
    );
  }
}
