// test/migration_test.dart
//
// Drift の SchemaVerifier を使った DB マイグレーション検証。
// `flutter test test/migration_test.dart` で実行可能。Android SDK や
// エミュレータは不要 (sqlite3_flutter_libs の Dart 実装でテストされる)。
//
// 検証対象:
// - v3 -> v5 のスキーマアップグレードが onUpgrade 通り走ること
// - v3 に入っていたデータが v5 でも保持されること
// - 新カラム (volume, age, forestSection, ..., markedForThinning) が
//   nullable / default 値で正しく追加されていること
// - 新テーブル LocalPlots が空テーブルとして作成されていること
// - 新カラム LocalTrees.plotId が追加されていること

import 'package:drift_dev/api/migrations_native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:forest_app/core/database/app_database.dart';

import 'generated_migrations/schema.dart';
import 'generated_migrations/schema_v3.dart' as v3;

void main() {
  late SchemaVerifier verifier;

  setUpAll(() {
    verifier = SchemaVerifier(GeneratedHelper());
  });

  test('v3 から v5 へのマイグレーションが onUpgrade 通り走る', () async {
    // v3 スキーマで生のテスト DB を作成
    final connection = await verifier.startAt(3);

    // 本番 AppDatabase クラスでマイグレーションを走らせ、
    // 結果が schema_v5.dart のスキーマと一致するか自動検証
    final db = AppDatabase.forTesting(connection);
    await verifier.migrateAndValidate(db, 5);
    await db.close();
  });

  test('v3 に登録した樹木データが v5 マイグレーション後も保持される', () async {
    // v3 スキーマでテスト DB を作成
    final schema = await verifier.schemaAt(3);

    // v3 スキーマで生 SQL を使ってテストデータを投入
    // (生成された schema_v3.dart には Companion クラスがないため)
    final oldDb = v3.DatabaseAtV3(schema.newConnection());

    await oldDb.customStatement(
      "INSERT INTO local_work_areas (id, name, boundary) VALUES (?, ?, ?)",
      [
        'work-1',
        'テスト林班',
        'POLYGON((139 35,139.01 35,139.01 35.01,139 35.01,139 35))'
      ],
    );

    await oldDb.customStatement(
      "INSERT INTO local_trees (id, species, location, work_area_id) "
      "VALUES (?, ?, ?, ?)",
      ['tree-1', 'スギ', 'POINT(139.005 35.005)', 'work-1'],
    );

    await oldDb.customStatement(
      "INSERT INTO local_trees (id, species, location, work_area_id) "
      "VALUES (?, ?, ?, ?)",
      ['tree-2', 'ヒノキ', 'POINT(139.006 35.006)', 'work-1'],
    );

    await oldDb.close();

    // v5 にマイグレーションした AppDatabase でデータを読む
    final db = AppDatabase.forTesting(schema.newConnection());

    // 作業エリアが保持されていること
    final workAreas = await db.select(db.localWorkAreas).get();
    expect(workAreas, hasLength(1));
    expect(workAreas.first.name, 'テスト林班');

    // 樹木 2 本が保持されていること
    final trees = await db.select(db.localTrees).get();
    expect(trees, hasLength(2));

    final tree1 = trees.firstWhere((t) => t.id == 'tree-1');
    expect(tree1.species, 'スギ');

    // v5 で追加された新カラムは null / default 値であること
    expect(tree1.volume, isNull);
    expect(tree1.age, isNull);
    expect(tree1.forestSection, isNull);
    expect(tree1.subSection, isNull);
    expect(tree1.treeNumber, isNull);
    expect(tree1.vigor, isNull);
    expect(tree1.pestDisease, isNull);
    expect(tree1.slope, isNull);
    expect(tree1.aspect, isNull);
    expect(tree1.notes, isNull);
    expect(tree1.markedForThinning, isFalse);
    expect(tree1.plotId, isNull);

    await db.close();
  });

  test('v5 マイグレーション後、LocalPlots テーブルが空で利用可能', () async {
    final schema = await verifier.schemaAt(3);
    final db = AppDatabase.forTesting(schema.newConnection());

    // マイグレーション完走後、新テーブルが空であること
    final plots = await db.select(db.localPlots).get();
    expect(plots, isEmpty);

    // 新規 Plot を insert できること
    await db.into(db.localPlots).insert(
          LocalPlotsCompanion.insert(
            id: 'plot-1',
            name: '標本区 A',
            shape: 'circle',
            centerLat: 35.005,
            centerLng: 139.005,
            size: 5.64, // 半径 5.64m = 100m²
            workAreaId: 'work-test',
          ),
        );

    final after = await db.select(db.localPlots).get();
    expect(after, hasLength(1));
    expect(after.first.name, '標本区 A');
    expect(after.first.shape, 'circle');

    await db.close();
  });

}
