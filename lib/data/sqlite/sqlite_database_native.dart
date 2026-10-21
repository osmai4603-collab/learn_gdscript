import 'package:sqlite3/sqlite3.dart';
import 'package:sqlite3/common.dart';

CommonDatabase openSqliteDatabase(String path, {required bool inMemory}) {
  return inMemory ? sqlite3.openInMemory() : sqlite3.open(path);
}
