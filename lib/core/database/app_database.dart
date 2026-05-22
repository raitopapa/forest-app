import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

class LocalWorkAreas extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get boundary => text()(); // WKT
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))(); // synced, dirty, deleted
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  
  @override
  Set<Column> get primaryKey => {id};
}

class LocalTrees extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get species => text()();
  RealColumn get height => real().nullable()();
  RealColumn get diameter => real().nullable()(); // DBH (胸高直径)
  TextColumn get healthStatus => text().nullable()();
  TextColumn get location => text()(); // WKT
  TextColumn get workAreaId => text().references(LocalWorkAreas, #id)();
  TextColumn get plotId => text().nullable()(); // プロットID (任意)
  TextColumn get photoUrl => text().nullable()();
  TextColumn get photoPath => text().nullable()();

  // 新規追加: 林業実務用フィールド
  RealColumn get volume => real().nullable()(); // 材積 (m³)
  IntColumn get age => integer().nullable()(); // 樹齢 (年)
  TextColumn get forestSection => text().nullable()(); // 林班
  TextColumn get subSection => text().nullable()(); // 小班
  TextColumn get treeNumber => text().nullable()(); // 立木番号
  TextColumn get vigor => text().nullable()(); // 樹勢 (A/B/C)
  TextColumn get pestDisease => text().nullable()(); // 病虫害情報
  RealColumn get slope => real().nullable()(); // 傾斜角度 (度)
  TextColumn get aspect => text().nullable()(); // 方位 (N/NE/E/SE/S/SW/W/NW)
  TextColumn get notes => text().nullable()(); // 備考
  BoolColumn get markedForThinning => boolean().withDefault(const Constant(false))(); // 間伐対象

  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalMapObjects extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get type => text()(); // point, line
  TextColumn get geometry => text()(); // WKT
  TextColumn get name => text().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get workAreaId => text().references(LocalWorkAreas, #id)();
  TextColumn get photoPath => text().nullable()(); // Path to local photo file
  TextColumn get attributes => text().nullable()(); // JSON string for custom attributes
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

class LocalPlots extends Table {
  TextColumn get id => text()(); // UUID
  TextColumn get name => text()();
  TextColumn get shape => text()(); // circle, square
  RealColumn get centerLat => real()();
  RealColumn get centerLng => real()();
  RealColumn get size => real()(); // 半径または一辺の長さ (m)
  TextColumn get workAreaId => text().references(LocalWorkAreas, #id)();
  TextColumn get description => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [LocalWorkAreas, LocalTrees, LocalMapObjects, LocalPlots])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// マイグレーションテスト等で QueryExecutor を直接差し替えるための constructor。
  /// 本番コードからは呼ばないこと。
  AppDatabase.forTesting(QueryExecutor e) : super(e);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(localMapObjects);
          }
          if (from < 3) {
            await m.addColumn(localMapObjects, localMapObjects.photoPath);
            await m.addColumn(localMapObjects, localMapObjects.attributes);
          }
          if (from < 4) {
            // 林業実務用フィールドを追加
            await m.addColumn(localTrees, localTrees.volume);
            await m.addColumn(localTrees, localTrees.age);
            await m.addColumn(localTrees, localTrees.forestSection);
            await m.addColumn(localTrees, localTrees.subSection);
            await m.addColumn(localTrees, localTrees.treeNumber);
            await m.addColumn(localTrees, localTrees.vigor);
            await m.addColumn(localTrees, localTrees.pestDisease);
            await m.addColumn(localTrees, localTrees.slope);
            await m.addColumn(localTrees, localTrees.aspect);
            await m.addColumn(localTrees, localTrees.notes);
            await m.addColumn(localTrees, localTrees.markedForThinning);
          }
          if (from < 5) {
            // プロットテーブルを追加
            await m.createTable(localPlots);
            // 樹木テーブルにplotIdを追加
            await m.addColumn(localTrees, localTrees.plotId);
          }
        },
      );

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'forest_app_db');
  }
}

