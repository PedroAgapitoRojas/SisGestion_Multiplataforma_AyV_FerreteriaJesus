import '../../../data/database/database_helper.dart';
import '../models/usuario.dart';

class UserService {
  final _db = DatabaseHelper.instance;

  Future<List<Usuario>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('usuarios', orderBy: 'nombre ASC');
    return maps.map(Usuario.fromMap).toList();
  }

  Future<int> create(Usuario u) async {
    final db = await _db.database;
    final map = u.toMap()..remove('id');
    return await db.insert('usuarios', map);
  }

  Future<int> update(Usuario u) async {
    final db = await _db.database;
    return await db.update(
      'usuarios', u.toMap(),
      where: 'id = ?', whereArgs: [u.id],
    );
  }

  Future<void> toggleActivo(int id, bool activo) async {
    final db = await _db.database;
    await db.update(
      'usuarios', {'activo': activo ? 1 : 0},
      where: 'id = ?', whereArgs: [id],
    );
  }

  Future<bool> emailExiste(String email, {int? excludeId}) async {
    final db = await _db.database;
    final r = await db.query(
      'usuarios',
      where: excludeId != null ? 'email = ? AND id != ?' : 'email = ?',
      whereArgs: excludeId != null ? [email, excludeId] : [email],
    );
    return r.isNotEmpty;
  }
}