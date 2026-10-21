import 'package:sqlite3/common.dart';

CommonDatabase openSqliteDatabase(String path, {required bool inMemory}) {
  throw UnsupportedError(
    'SQLite persistence is not configured for this platform. '
    'Use a supported native target.',
  );
}
