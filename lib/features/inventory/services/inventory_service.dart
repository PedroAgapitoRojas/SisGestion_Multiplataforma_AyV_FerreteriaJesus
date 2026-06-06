import '../../../data/database/database_helper.dart';
import '../models/producto.dart';

class InventoryService {
  final _db = DatabaseHelper.instance;

  Future<List<Producto>> getAll({String? query}) async {
    final db = await _db.database;
    List<Map<String, dynamic>> maps;
    if (query != null && query.isNotEmpty) {
      maps = await db.query(
        'productos',
        where: 'activo = 1 AND (nombre LIKE ? OR codigo LIKE ? OR categoria LIKE ?)',
        whereArgs: ['%$query%', '%$query%', '%$query%'],
        orderBy: 'nombre ASC',
      );
    } else {
      maps = await db.query(
        'productos',
        where: 'activo = 1',
        orderBy: 'nombre ASC',
      );
    }
    return maps.map(Producto.fromMap).toList();
  }

  Future<List<Producto>> getStockBajo() async {
    final db = await _db.database;
    final maps = await db.rawQuery(
      'SELECT * FROM productos WHERE activo = 1 AND stock <= stock_minimo ORDER BY stock ASC',
    );
    return maps.map(Producto.fromMap).toList();
  }

  Future<int> create(Producto p) async {
    final db = await _db.database;
    final map = p.toMap()..remove('id');
    return await db.insert('productos', map);
  }

  Future<int> update(Producto p) async {
    final db = await _db.database;
    return await db.update(
      'productos', p.toMap(),
      where: 'id = ?', whereArgs: [p.id],
    );
  }

  Future<void> delete(int id) async {
    final db = await _db.database;
    await db.update(
      'productos', {'activo': 0},
      where: 'id = ?', whereArgs: [id],
    );
  }

  Future<int> getTotalProductos() async {
    final db = await _db.database;
    final r = await db.rawQuery(
      'SELECT COUNT(*) as c FROM productos WHERE activo = 1',
    );
    return (r.first['c'] as int?) ?? 0;
  }

  Future<bool> codigoExiste(String codigo, {int? excludeId}) async {
    final db = await _db.database;
    final r = await db.query(
      'productos',
      where: excludeId != null
          ? 'codigo = ? AND id != ? AND activo = 1'
          : 'codigo = ? AND activo = 1',
      whereArgs: excludeId != null ? [codigo, excludeId] : [codigo],
    );
    return r.isNotEmpty;
  }
}