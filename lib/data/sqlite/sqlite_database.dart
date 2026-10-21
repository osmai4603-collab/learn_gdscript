import 'package:sqlite3/common.dart';

import 'sqlite_database_native.dart'
    if (dart.library.js_interop) 'sqlite_database_unsupported.dart'
    as platform;

CommonDatabase openSqliteDatabase(String path, {required bool inMemory}) {
  return platform.openSqliteDatabase(path, inMemory: inMemory);
}
