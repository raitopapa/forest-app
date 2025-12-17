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
  RealColumn get diameter => real().nullable()();
  TextColumn get healthStatus => text().nullable()();
  TextColumn get location => text()(); // WKT
  TextColumn get workAreaId => text().references(LocalWorkAreas, #id)();
  TextColumn get photoUrl => text().nullable()();
  TextColumn get photoPath => text().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('synced'))();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [LocalWorkAreas, LocalTrees])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return driftDatabase(name: 'forest_app_db');
  }
}
