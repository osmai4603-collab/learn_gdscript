import '../sqlite/database_helper.dart';

class HomeDashboardRepository {
  HomeDashboardRepository(this._databaseHelper);

  final DatabaseHelper _databaseHelper;

  Future<String?> loadPlaygroundCode(String visitorId) async {
    final database = await _databaseHelper.database;
    final rows = database.select(
      'SELECT playground_code FROM home_dashboard_state WHERE visitor_id = ?',
      [visitorId],
    );
    if (rows.isEmpty) return null;
    return rows.single['playground_code'] as String;
  }

  Future<void> savePlaygroundCode({
    required String visitorId,
    required String code,
    required DateTime updatedAt,
  }) async {
    final database = await _databaseHelper.database;
    database.execute(
      '''
      INSERT INTO home_dashboard_state (visitor_id, playground_code, updated_at)
      VALUES (?, ?, ?)
      ON CONFLICT(visitor_id) DO UPDATE SET
        playground_code = excluded.playground_code,
        updated_at = excluded.updated_at
      ''',
      [visitorId, code, updatedAt.toIso8601String()],
    );
  }
}
