import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService();
});

/// Backup frequency options
enum BackupFrequency {
  manual,  // Only manual backups
  daily,
  weekly,
}

/// Service for managing local database backups.
class BackupService {
  static const String _lastBackupKey = 'last_backup_timestamp';
  static const String _frequencyKey = 'backup_frequency';
  static const String _dbFileName = 'forest_app_db.sqlite';
  static const int _maxBackups = 5; // Keep last 5 backups

  /// Get the backup directory path.
  Future<Directory> getBackupDirectory() async {
    final appDir = await getApplicationDocumentsDirectory();
    final backupDir = Directory(p.join(appDir.path, 'backups'));
    if (!await backupDir.exists()) {
      await backupDir.create(recursive: true);
    }
    return backupDir;
  }

  /// Get the database file path.
  Future<File> getDatabaseFile() async {
    final appDir = await getApplicationDocumentsDirectory();
    return File(p.join(appDir.path, _dbFileName));
  }

  /// Create a backup of the current database.
  Future<File?> createBackup() async {
    try {
      final dbFile = await getDatabaseFile();
      if (!await dbFile.exists()) {
        return null;
      }

      final backupDir = await getBackupDirectory();
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
      final backupFileName = 'backup_$timestamp.sqlite';
      final backupFile = File(p.join(backupDir.path, backupFileName));

      await dbFile.copy(backupFile.path);

      // Save last backup timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_lastBackupKey, DateTime.now().millisecondsSinceEpoch);

      // Cleanup old backups
      await _cleanupOldBackups();

      return backupFile;
    } catch (e) {
      print('Backup failed: $e');
      return null;
    }
  }

  /// Restore database from a backup file.
  Future<bool> restoreFromBackup(File backupFile) async {
    try {
      if (!await backupFile.exists()) {
        return false;
      }

      final dbFile = await getDatabaseFile();

      // Create a safety backup before restore
      if (await dbFile.exists()) {
        final dir = await getBackupDirectory();
        final safetyBackup = File(p.join(dir.path, 'pre_restore_backup.sqlite'));
        await dbFile.copy(safetyBackup.path);
      }

      // Replace database with backup
      await backupFile.copy(dbFile.path);

      return true;
    } catch (e) {
      print('Restore failed: $e');
      return false;
    }
  }

  /// Get list of available backups sorted by date (newest first).
  Future<List<BackupInfo>> getAvailableBackups() async {
    final backupDir = await getBackupDirectory();
    if (!await backupDir.exists()) {
      return [];
    }

    final files = await backupDir
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.sqlite'))
        .toList();

    final backups = <BackupInfo>[];
    for (final entity in files) {
      final file = entity as File;
      final stat = await file.stat();
      final name = p.basename(file.path);
      
      // Skip safety backup in listing
      if (name == 'pre_restore_backup.sqlite') continue;

      backups.add(BackupInfo(
        file: file,
        name: name,
        createdAt: stat.modified,
        sizeBytes: stat.size,
      ));
    }

    backups.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return backups;
  }

  /// Delete a specific backup.
  Future<bool> deleteBackup(File backupFile) async {
    try {
      if (await backupFile.exists()) {
        await backupFile.delete();
        return true;
      }
      return false;
    } catch (e) {
      print('Delete backup failed: $e');
      return false;
    }
  }

  /// Get/set backup frequency.
  Future<BackupFrequency> getBackupFrequency() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_frequencyKey) ?? 0;
    return BackupFrequency.values[index.clamp(0, BackupFrequency.values.length - 1)];
  }

  Future<void> setBackupFrequency(BackupFrequency frequency) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_frequencyKey, frequency.index);
  }

  /// Get last backup timestamp.
  Future<DateTime?> getLastBackupTime() async {
    final prefs = await SharedPreferences.getInstance();
    final timestamp = prefs.getInt(_lastBackupKey);
    if (timestamp == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  /// Check if backup is needed based on frequency setting.
  Future<bool> isBackupNeeded() async {
    final frequency = await getBackupFrequency();
    if (frequency == BackupFrequency.manual) return false;

    final lastBackup = await getLastBackupTime();
    if (lastBackup == null) return true;

    final now = DateTime.now();
    final diff = now.difference(lastBackup);

    switch (frequency) {
      case BackupFrequency.daily:
        return diff.inHours >= 24;
      case BackupFrequency.weekly:
        return diff.inDays >= 7;
      case BackupFrequency.manual:
        return false;
    }
  }

  /// Perform auto-backup if needed.
  Future<void> performAutoBackupIfNeeded() async {
    if (await isBackupNeeded()) {
      await createBackup();
    }
  }

  /// Cleanup old backups, keeping only the most recent ones.
  Future<void> _cleanupOldBackups() async {
    final backups = await getAvailableBackups();
    if (backups.length > _maxBackups) {
      // Delete oldest backups
      for (int i = _maxBackups; i < backups.length; i++) {
        await deleteBackup(backups[i].file);
      }
    }
  }
}

/// Information about a backup file.
class BackupInfo {
  final File file;
  final String name;
  final DateTime createdAt;
  final int sizeBytes;

  BackupInfo({
    required this.file,
    required this.name,
    required this.createdAt,
    required this.sizeBytes,
  });

  String get formattedSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  String get formattedDate {
    return '${createdAt.year}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.day.toString().padLeft(2, '0')} '
           '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}
