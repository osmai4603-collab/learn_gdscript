import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/common.dart';

import '../../core/constants/app_constants.dart';
import 'migrations.dart';
import 'sqlite_database.dart';

class DatabaseHelper {
  DatabaseHelper({
    Future<String> Function()? databasePathProvider,
    bool inMemory = false,
  }) : _databasePathProvider = databasePathProvider,
       _inMemory = inMemory;

  final Future<String> Function()? _databasePathProvider;
  final bool _inMemory;
  Future<CommonDatabase>? _opening;
  CommonDatabase? _database;

  Future<CommonDatabase> get database async {
    if (_database case final database?) return Future.value(database);
    final opening = _opening ??= _open();
    try {
      return await opening;
    } on Object {
      if (identical(_opening, opening)) _opening = null;
      rethrow;
    }
  }

  Future<CommonDatabase> _open() async {
    final String path;
    if (_inMemory) {
      path = ':memory:';
    } else if (_databasePathProvider case final provider?) {
      path = await provider();
    } else {
      if (kIsWeb) {
        throw UnsupportedError(
          'Web persistence requires a configured SQLite WebAssembly backend.',
        );
      }
      final directory = await getApplicationSupportDirectory();
      path = '${directory.path}/${AppConstants.databaseFileName}';
    }

    final database = openSqliteDatabase(path, inMemory: _inMemory);
    try {
      database.execute('PRAGMA foreign_keys = ON');
      migrateDatabase(database);
    } on Object {
      database.close();
      rethrow;
    }
    _database = database;
    return database;
  }

  Future<void> close() async {
    final opening = _opening;
    if (opening != null) {
      await opening;
    }
    _database?.close();
    _database = null;
    _opening = null;
  }
}
