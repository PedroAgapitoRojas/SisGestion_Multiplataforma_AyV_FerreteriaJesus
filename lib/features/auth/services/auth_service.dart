import '../../../data/database/database_helper.dart';

class AuthService {
  final _db = DatabaseHelper.instance;

  Future<Map<String, dynamic>?> login({
    required String email,
    required String password,
  }) async {
    final db = await _db.database;
    final result = await db.query(
      'usuarios',
      where: 'email = ? AND password = ? AND activo = 1',
      whereArgs: [email.trim(), password],
    );
    return result.isNotEmpty ? result.first : null;
  }
}