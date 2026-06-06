import '../../inventory/models/producto.dart';

class ItemCarrito {
  final Producto producto;
  int cantidad;

  ItemCarrito({required this.producto, this.cantidad = 1});

  double get subtotal => producto.precioVenta * cantidad;
}

class Venta {
  final int? id;
  final int usuarioId;
  final double total;
  final String metodoPago;
  final String estado;
  final String? observacion;
  final String createdAt;

  Venta({
    this.id,
    required this.usuarioId,
    required this.total,
    required this.metodoPago,
    this.estado = 'completada',
    this.observacion,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
    'usuario_id': usuarioId,
    'total': total,
    'metodo_pago': metodoPago,
    'estado': estado,
    'observacion': observacion,
    'created_at': createdAt,
  };

  factory Venta.fromMap(Map<String, dynamic> m) => Venta(
    id: m['id'],
    usuarioId: m['usuario_id'],
    total: (m['total'] as num).toDouble(),
    metodoPago: m['metodo_pago'],
    estado: m['estado'],
    observacion: m['observacion'],
    createdAt: m['created_at'],
  );
}