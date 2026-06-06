import '../../../data/database/database_helper.dart';
import '../models/venta.dart';

class SalesService {
  final _db = DatabaseHelper.instance;

  Future<int> registrarVenta({
    required int usuarioId,
    required List<ItemCarrito> carrito,
    required String metodoPago,
    String? observacion,
  }) async {
    final db = await _db.database;
    final total = carrito.fold<double>(0, (s, i) => s + i.subtotal);

    return await db.transaction((txn) async {
      final ventaId = await txn.insert('ventas', {
        'usuario_id': usuarioId,
        'total': total,
        'metodo_pago': metodoPago,
        'estado': 'completada',
        'observacion': observacion,
        'created_at': DateTime.now().toIso8601String(),
      });
      for (final item in carrito) {
        await txn.insert('detalle_ventas', {
          'venta_id': ventaId,
          'producto_id': item.producto.id,
          'cantidad': item.cantidad,
          'precio_unitario': item.producto.precioVenta,
          'subtotal': item.subtotal,
        });
        await txn.rawUpdate(
          'UPDATE productos SET stock = stock - ? WHERE id = ?',
          [item.cantidad, item.producto.id],
        );
      }
      return ventaId;
    });
  }

  Future<double> getTotalVentasHoy() async {
    final db = await _db.database;
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day).toIso8601String();
    final fin = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59).toIso8601String();
    final r = await db.rawQuery(
      'SELECT COALESCE(SUM(total), 0) as t FROM ventas WHERE created_at BETWEEN ? AND ?',
      [inicio, fin],
    );
    return (r.first['t'] as num?)?.toDouble() ?? 0;
  }

  Future<Map<String, double>> getVentasPorDia({int dias = 7}) async {
    final db = await _db.database;
    final Map<String, double> resultado = {};
    for (int i = dias - 1; i >= 0; i--) {
      final fecha = DateTime.now().subtract(Duration(days: i));
      final inicio = DateTime(fecha.year, fecha.month, fecha.day).toIso8601String();
      final fin = DateTime(fecha.year, fecha.month, fecha.day, 23, 59, 59).toIso8601String();
      final r = await db.rawQuery(
        'SELECT COALESCE(SUM(total), 0) as t FROM ventas WHERE created_at BETWEEN ? AND ?',
        [inicio, fin],
      );
      resultado['${fecha.day}/${fecha.month}'] =
          (r.first['t'] as num?)?.toDouble() ?? 0;
    }
    return resultado;
  }

  Future<List<Map<String, dynamic>>> getVentas({
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final db = await _db.database;
    String where = '1=1';
    final List args = [];
    if (desde != null) {
      where += ' AND v.created_at >= ?';
      args.add(desde.toIso8601String());
    }
    if (hasta != null) {
      where += ' AND v.created_at <= ?';
      args.add(hasta.toIso8601String());
    }
    return await db.rawQuery(
      '''SELECT v.*, u.nombre as vendedor
         FROM ventas v
         JOIN usuarios u ON v.usuario_id = u.id
         WHERE $where
         ORDER BY v.created_at DESC''',
      args,
    );
  }

  Future<Map<String, double>> getVentasPorMetodoPago({
    DateTime? desde,
    DateTime? hasta,
  }) async {
    final db = await _db.database;
    final hoy = DateTime.now();
    final inicio = desde ?? DateTime(hoy.year, hoy.month, 1);
    final fin = hasta ?? DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59);
    final r = await db.rawQuery(
      '''SELECT metodo_pago, COALESCE(SUM(total), 0) as t
         FROM ventas
         WHERE created_at BETWEEN ? AND ?
         GROUP BY metodo_pago''',
      [inicio.toIso8601String(), fin.toIso8601String()],
    );
    return {for (var row in r) row['metodo_pago'] as String: (row['t'] as num).toDouble()};
  }

  Future<int> contarVentasHoy() async {
    final db = await _db.database;
    final hoy = DateTime.now();
    final inicio = DateTime(hoy.year, hoy.month, hoy.day).toIso8601String();
    final fin = DateTime(hoy.year, hoy.month, hoy.day, 23, 59, 59).toIso8601String();
    final r = await db.rawQuery(
      'SELECT COUNT(*) as c FROM ventas WHERE created_at BETWEEN ? AND ?',
      [inicio, fin],
    );
    return (r.first['c'] as int?) ?? 0;
  }
}