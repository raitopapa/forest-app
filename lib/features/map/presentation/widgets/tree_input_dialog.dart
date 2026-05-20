import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../domain/models/tree.dart';

/// 拡張樹木入力ダイアログ - 林業実務対応
class TreeInputDialog extends StatefulWidget {
  final Function({
    required String species,
    double? height,
    double? diameter,
    String? healthStatus,
    String? photoPath,
    double? volume,
    int? age,
    String? forestSection,
    String? subSection,
    String? treeNumber,
    String? vigor,
    String? pestDisease,
    double? slope,
    String? aspect,
    String? notes,
    bool markedForThinning,
  }) onSubmit;

  final String? initialSpecies;
  final double? initialHeight;
  final double? initialDiameter;
  final String locationText;

  const TreeInputDialog({
    super.key,
    required this.onSubmit,
    required this.locationText,
    this.initialSpecies,
    this.initialHeight,
    this.initialDiameter,
  });

  @override
  State<TreeInputDialog> createState() => _TreeInputDialogState();
}

class _TreeInputDialogState extends State<TreeInputDialog> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _picker = ImagePicker();

  // 基本情報
  final _speciesController = TextEditingController();
  final _heightController = TextEditingController();
  final _diameterController = TextEditingController();
  final _healthStatusController = TextEditingController();
  String? _photoPath;

  // 林業情報
  final _volumeController = TextEditingController();
  final _ageController = TextEditingController();
  final _forestSectionController = TextEditingController();
  final _subSectionController = TextEditingController();
  final _treeNumberController = TextEditingController();
  TreeVigor? _selectedVigor;
  final _pestDiseaseController = TextEditingController();
  final _slopeController = TextEditingController();
  Aspect? _selectedAspect;
  final _notesController = TextEditingController();
  bool _markedForThinning = false;

  // 自動計算された材積
  double? _calculatedVolume;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    if (widget.initialSpecies != null) {
      _speciesController.text = widget.initialSpecies!;
    }
    if (widget.initialHeight != null) {
      _heightController.text = widget.initialHeight.toString();
    }
    if (widget.initialDiameter != null) {
      _diameterController.text = widget.initialDiameter.toString();
    }

    // 材積の自動計算をリスニング
    _heightController.addListener(_recalculateVolume);
    _diameterController.addListener(_recalculateVolume);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _speciesController.dispose();
    _heightController.dispose();
    _diameterController.dispose();
    _healthStatusController.dispose();
    _volumeController.dispose();
    _ageController.dispose();
    _forestSectionController.dispose();
    _subSectionController.dispose();
    _treeNumberController.dispose();
    _pestDiseaseController.dispose();
    _slopeController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _recalculateVolume() {
    final height = double.tryParse(_heightController.text);
    final diameter = double.tryParse(_diameterController.text);

    if (height != null && diameter != null && height > 0 && diameter > 0) {
      setState(() {
        _calculatedVolume = 0.000045 * diameter * diameter * height;
      });
    } else {
      setState(() {
        _calculatedVolume = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ヘッダー
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green[700],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(4),
                topRight: Radius.circular(4),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.park, color: Colors.white),
                const SizedBox(width: 8),
                const Text(
                  '樹木を登録',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // タブバー
          Container(
            color: Colors.grey[200],
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.green[700],
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.green[700],
              tabs: const [
                Tab(text: '基本情報', icon: Icon(Icons.info)),
                Tab(text: '林業情報', icon: Icon(Icons.forest)),
              ],
            ),
          ),

          // タブコンテンツ
          Flexible(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildBasicInfoTab(),
                _buildForestryInfoTab(),
              ],
            ),
          ),

          // フッター
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('キャンセル'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _handleSubmit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('登録'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 位置情報
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on, color: Colors.blue, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '位置: ${widget.locationText}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 樹種
          TextField(
            controller: _speciesController,
            decoration: const InputDecoration(
              labelText: '樹種 *',
              hintText: 'スギ、ヒノキ、マツ等',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.nature),
            ),
          ),
          const SizedBox(height: 16),

          // 樹高と胸高直径
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _heightController,
                  decoration: const InputDecoration(
                    labelText: '樹高 (m)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.height),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _diameterController,
                  decoration: const InputDecoration(
                    labelText: '胸高直径 (cm)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.straighten),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 材積表示（自動計算）
          if (_calculatedVolume != null)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calculate, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    '材積（自動計算）: ${_calculatedVolume!.toStringAsFixed(4)} m³',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),

          // 健康状態
          TextField(
            controller: _healthStatusController,
            decoration: const InputDecoration(
              labelText: '健康状態',
              hintText: '良好、要注意等',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.health_and_safety),
            ),
          ),
          const SizedBox(height: 16),

          // 写真
          const Text('写真', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (_photoPath != null)
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_photoPath!),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _photoPath = null),
                  icon: const Icon(Icons.cancel, color: Colors.red),
                ),
              ],
            )
          else
            OutlinedButton.icon(
              onPressed: () async {
                final pickedFile = await _picker.pickImage(source: ImageSource.camera);
                if (pickedFile != null) {
                  setState(() => _photoPath = pickedFile.path);
                }
              },
              icon: const Icon(Icons.camera_alt),
              label: const Text('写真を撮る'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildForestryInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 林班・小班
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _forestSectionController,
                  decoration: const InputDecoration(
                    labelText: '林班',
                    hintText: '例: 1班',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.map),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _subSectionController,
                  decoration: const InputDecoration(
                    labelText: '小班',
                    hintText: '例: い',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_searching),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 立木番号
          TextField(
            controller: _treeNumberController,
            decoration: const InputDecoration(
              labelText: '立木番号',
              hintText: '個体識別番号',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.tag),
            ),
          ),
          const SizedBox(height: 16),

          // 樹齢
          TextField(
            controller: _ageController,
            decoration: const InputDecoration(
              labelText: '樹齢 (年)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),

          // 樹勢
          const Text('樹勢評価', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          SegmentedButton<TreeVigor>(
            segments: const [
              ButtonSegment(value: TreeVigor.excellent, label: Text('A級'), icon: Icon(Icons.star)),
              ButtonSegment(value: TreeVigor.good, label: Text('B級'), icon: Icon(Icons.check_circle)),
              ButtonSegment(value: TreeVigor.poor, label: Text('C級'), icon: Icon(Icons.warning)),
            ],
            selected: _selectedVigor != null ? {_selectedVigor!} : {},
            onSelectionChanged: (Set<TreeVigor> selected) {
              setState(() => _selectedVigor = selected.firstOrNull);
            },
            emptySelectionAllowed: true,
          ),
          const SizedBox(height: 16),

          // 傾斜と方位
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _slopeController,
                  decoration: const InputDecoration(
                    labelText: '傾斜 (度)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.terrain),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: DropdownButtonFormField<Aspect>(
                  decoration: const InputDecoration(
                    labelText: '方位',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.explore),
                  ),
                  value: _selectedAspect,
                  items: Aspect.values.map((aspect) {
                    return DropdownMenuItem(
                      value: aspect,
                      child: Text(_getAspectLabel(aspect)),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => _selectedAspect = value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 病虫害
          TextField(
            controller: _pestDiseaseController,
            decoration: const InputDecoration(
              labelText: '病虫害情報',
              hintText: '被害の種類や程度',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.bug_report),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 16),

          // 間伐対象
          CheckboxListTile(
            title: const Text('間伐対象としてマーク'),
            subtitle: const Text('この樹木を間伐予定リストに追加'),
            value: _markedForThinning,
            onChanged: (value) => setState(() => _markedForThinning = value ?? false),
            secondary: const Icon(Icons.content_cut),
          ),
          const SizedBox(height: 16),

          // 備考
          TextField(
            controller: _notesController,
            decoration: const InputDecoration(
              labelText: '備考',
              hintText: 'その他メモ',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.note),
            ),
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  String _getAspectLabel(Aspect aspect) {
    switch (aspect) {
      case Aspect.north:
        return '北 (N)';
      case Aspect.northEast:
        return '北東 (NE)';
      case Aspect.east:
        return '東 (E)';
      case Aspect.southEast:
        return '南東 (SE)';
      case Aspect.south:
        return '南 (S)';
      case Aspect.southWest:
        return '南西 (SW)';
      case Aspect.west:
        return '西 (W)';
      case Aspect.northWest:
        return '北西 (NW)';
    }
  }

  void _handleSubmit() {
    if (_speciesController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('樹種を入力してください')),
      );
      return;
    }

    widget.onSubmit(
      species: _speciesController.text,
      height: double.tryParse(_heightController.text),
      diameter: double.tryParse(_diameterController.text),
      healthStatus: _healthStatusController.text.isEmpty ? null : _healthStatusController.text,
      photoPath: _photoPath,
      volume: _volumeController.text.isEmpty ? _calculatedVolume : double.tryParse(_volumeController.text),
      age: int.tryParse(_ageController.text),
      forestSection: _forestSectionController.text.isEmpty ? null : _forestSectionController.text,
      subSection: _subSectionController.text.isEmpty ? null : _subSectionController.text,
      treeNumber: _treeNumberController.text.isEmpty ? null : _treeNumberController.text,
      vigor: _selectedVigor?.toDbString(),
      pestDisease: _pestDiseaseController.text.isEmpty ? null : _pestDiseaseController.text,
      slope: double.tryParse(_slopeController.text),
      aspect: _selectedAspect?.toDbString(),
      notes: _notesController.text.isEmpty ? null : _notesController.text,
      markedForThinning: _markedForThinning,
    );

    Navigator.pop(context);
  }
}
