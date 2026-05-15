import 'package:flutter/material.dart';

/// Supported attribute value types.
enum AttributeType { text, number, date }

enum SurveyTemplateType { custom, treeSurvey, boundaryCheck, routeInspection }

/// A single custom attribute entry.
class CustomAttribute {
  String key;
  dynamic value;
  AttributeType type;

  CustomAttribute({required this.key, this.value, this.type = AttributeType.text});
}

/// Dialog for editing custom attributes (key-value pairs).
/// Returns a Map<String, dynamic> on save, or null if cancelled.
Future<Map<String, dynamic>?> showAttributeEditorDialog({
  required BuildContext context,
  Map<String, dynamic>? initialAttributes,
}) async {
  return showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => _AttributeEditorDialog(initialAttributes: initialAttributes),
  );
}

class _AttributeEditorDialog extends StatefulWidget {
  final Map<String, dynamic>? initialAttributes;

  const _AttributeEditorDialog({this.initialAttributes});

  @override
  State<_AttributeEditorDialog> createState() => _AttributeEditorDialogState();
}

class _AttributeEditorDialogState extends State<_AttributeEditorDialog> {
  final List<CustomAttribute> _attributes = [];
  final _newKeyController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  SurveyTemplateType _selectedTemplate = SurveyTemplateType.custom;

  @override
  void initState() {
    super.initState();
    // Load initial attributes
    if (widget.initialAttributes != null) {
      widget.initialAttributes!.forEach((key, value) {
        AttributeType type = AttributeType.text;
        if (value is num) {
          type = AttributeType.number;
        } else if (value is DateTime) {
          type = AttributeType.date;
        }
        _attributes.add(CustomAttribute(key: key, value: value, type: type));
      });
    }
  }

  @override
  void dispose() {
    _newKeyController.dispose();
    super.dispose();
  }

  void _addAttribute() {
    final key = _newKeyController.text.trim();
    if (key.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('キーを入力してください')),
      );
      return;
    }
    if (_attributes.any((attr) => attr.key == key)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('同じキーが既に存在します')),
      );
      return;
    }
    setState(() {
      _attributes.add(CustomAttribute(key: key, value: ''));
      _newKeyController.clear();
    });
  }

  void _removeAttribute(int index) {
    setState(() {
      _attributes.removeAt(index);
    });
  }

  void _save() {
    final requiredKeys = _requiredKeysForTemplate(_selectedTemplate);
    final missing = <String>[];
    for (final key in requiredKeys) {
      CustomAttribute? attr;
      for (final candidate in _attributes) {
        if (candidate.key == key) {
          attr = candidate;
          break;
        }
      }
      final value = attr?.value;
      final isEmpty = value == null || value.toString().trim().isEmpty;
      if (isEmpty) missing.add(key);
    }

    if (missing.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('必須項目が未入力です: ${missing.join(', ')}')),
      );
      return;
    }

    final result = <String, dynamic>{};
    for (final attr in _attributes) {
      if (attr.key.isNotEmpty) {
        dynamic valueToSave = attr.value;
        // Convert based on type
        if (attr.type == AttributeType.number) {
          valueToSave = num.tryParse(attr.value?.toString() ?? '') ?? 0;
        } else if (attr.type == AttributeType.date && attr.value is DateTime) {
          valueToSave = (attr.value as DateTime).toIso8601String();
        }
        result[attr.key] = valueToSave;
      }
    }
    Navigator.of(context).pop(result);
  }

  List<String> _requiredKeysForTemplate(SurveyTemplateType template) {
    switch (template) {
      case SurveyTemplateType.treeSurvey:
        return const ['樹種', '樹高_m', '胸高直径_cm'];
      case SurveyTemplateType.boundaryCheck:
        return const ['境界杭番号', '破損有無', '確認日'];
      case SurveyTemplateType.routeInspection:
        return const ['路網種別', '通行可否'];
      case SurveyTemplateType.custom:
        return const [];
    }
  }

  void _applyTemplate(SurveyTemplateType template) {
    if (template == SurveyTemplateType.custom) return;

    final templateAttributes = switch (template) {
      SurveyTemplateType.treeSurvey => [
        CustomAttribute(key: '樹種', value: '', type: AttributeType.text),
        CustomAttribute(key: '樹高_m', value: '', type: AttributeType.number),
        CustomAttribute(key: '胸高直径_cm', value: '', type: AttributeType.number),
        CustomAttribute(key: '健康状態', value: '', type: AttributeType.text),
      ],
      SurveyTemplateType.boundaryCheck => [
        CustomAttribute(key: '境界杭番号', value: '', type: AttributeType.text),
        CustomAttribute(key: '破損有無', value: '', type: AttributeType.text),
        CustomAttribute(key: '確認日', value: DateTime.now(), type: AttributeType.date),
      ],
      SurveyTemplateType.routeInspection => [
        CustomAttribute(key: '路網種別', value: '', type: AttributeType.text),
        CustomAttribute(key: '通行可否', value: '', type: AttributeType.text),
        CustomAttribute(key: '危険度', value: '', type: AttributeType.text),
      ],
      SurveyTemplateType.custom => <CustomAttribute>[],
    };

    final existingKeys = _attributes.map((e) => e.key).toSet();
    setState(() {
      for (final attr in templateAttributes) {
        if (!existingKeys.contains(attr.key)) {
          _attributes.add(attr);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('カスタム属性'),
      content: SizedBox(
        width: double.maxFinite,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Add new attribute
              DropdownButtonFormField<SurveyTemplateType>(
                value: _selectedTemplate,
                decoration: const InputDecoration(
                  labelText: '調査テンプレート',
                  isDense: true,
                ),
                items: const [
                  DropdownMenuItem(value: SurveyTemplateType.custom, child: Text('カスタム')),
                  DropdownMenuItem(value: SurveyTemplateType.treeSurvey, child: Text('毎木調査')),
                  DropdownMenuItem(value: SurveyTemplateType.boundaryCheck, child: Text('境界確認')),
                  DropdownMenuItem(value: SurveyTemplateType.routeInspection, child: Text('路網点検')),
                ],
                onChanged: (v) {
                  if (v == null) return;
                  setState(() => _selectedTemplate = v);
                  _applyTemplate(v);
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newKeyController,
                      decoration: const InputDecoration(
                        hintText: '新しいキー名',
                        isDense: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green),
                    onPressed: _addAttribute,
                    tooltip: '属性を追加',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Existing attributes
              if (_attributes.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('属性がありません', style: TextStyle(color: Colors.grey)),
                )
              else
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _attributes.length,
                    itemBuilder: (context, index) {
                      final attr = _attributes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              // Key
                              SizedBox(
                                width: 80,
                                child: Text(
                                  attr.key,
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              // Type selector
                              DropdownButton<AttributeType>(
                                value: attr.type,
                                isDense: true,
                                underline: const SizedBox.shrink(),
                                items: const [
                                  DropdownMenuItem(value: AttributeType.text, child: Icon(Icons.text_fields, size: 18)),
                                  DropdownMenuItem(value: AttributeType.number, child: Icon(Icons.numbers, size: 18)),
                                  DropdownMenuItem(value: AttributeType.date, child: Icon(Icons.calendar_today, size: 18)),
                                ],
                                onChanged: (type) {
                                  if (type != null) {
                                    setState(() => attr.type = type);
                                  }
                                },
                              ),
                              const SizedBox(width: 8),
                              // Value input
                              Expanded(
                                child: _buildValueInput(attr),
                              ),
                              // Delete button
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red, size: 20),
                                onPressed: () => _removeAttribute(index),
                                tooltip: '削除',
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('キャンセル'),
        ),
        ElevatedButton(
          onPressed: _save,
          child: const Text('保存'),
        ),
      ],
    );
  }

  Widget _buildValueInput(CustomAttribute attr) {
    switch (attr.type) {
      case AttributeType.number:
        return TextField(
          decoration: const InputDecoration(hintText: '数値', isDense: true),
          keyboardType: TextInputType.number,
          controller: TextEditingController(text: attr.value?.toString() ?? ''),
          onChanged: (val) => attr.value = val,
        );
      case AttributeType.date:
        final dateValue = attr.value is DateTime ? attr.value as DateTime : DateTime.now();
        return InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: dateValue,
              firstDate: DateTime(1900),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              setState(() => attr.value = picked);
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(isDense: true),
            child: Text(
              attr.value is DateTime
                  ? '${(attr.value as DateTime).year}/${(attr.value as DateTime).month}/${(attr.value as DateTime).day}'
                  : '日付を選択',
            ),
          ),
        );
      case AttributeType.text:
      default:
        return TextField(
          decoration: const InputDecoration(hintText: '値', isDense: true),
          controller: TextEditingController(text: attr.value?.toString() ?? ''),
          onChanged: (val) => attr.value = val,
        );
    }
  }
}
