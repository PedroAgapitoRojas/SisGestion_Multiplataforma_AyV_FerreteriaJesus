class Producto {
  final int? id;
  final String nombre;
  final String codigo;
  final String categoria;
  final double precioCompra;
  final double precioVenta;
  final int stock;
  final int stockMinimo;
  final String unidad;
  final bool activo;
  final String createdAt;

  Producto({
    this.id,
    required this.nombre,
    required this.codigo,
    required this.categoria,
    required this.precioCompra,
    required this.precioVenta,
    required this.stock,
    this.stockMinimo = 5,
    this.unidad = 'unidad',
    this.activo = true,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  bool get stockBajo => stock <= stockMinimo;

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'codigo': codigo,
    'categoria': categoria,
    'precio_compra': precioCompra,
    'precio_venta': precioVenta,
    'stock': stock,
    'stock_minimo': stockMinimo,
    'unidad': unidad,
    'activo': activo ? 1 : 0,
    'created_at': createdAt,
  };

  factory Producto.fromMap(Map<String, dynamic> m) => Producto(
    id: m['id'],
    nombre: m['nombre'],
    codigo: m['codigo'],
    categoria: m['categoria'],
    precioCompra: (m['precio_compra'] as num).toDouble(),
    precioVenta: (m['precio_venta'] as num).toDouble(),
    stock: m['stock'],
    stockMinimo: m['stock_minimo'] ?? 5,
    unidad: m['unidad'] ?? 'unidad',
    activo: m['activo'] == 1,
    createdAt: m['created_at'],
  );

  Producto copyWith({
    int? stock,
    double? precioVenta,
    double? precioCompra,
    String? nombre,
    String? codigo,
    String? categoria,
    String? unidad,
    int? stockMinimo,
    bool? activo,
  }) => Producto(
    id: id,
    nombre: nombre ?? this.nombre,
    codigo: codigo ?? this.codigo,
    categoria: categoria ?? this.categoria,
    precioCompra: precioCompra ?? this.precioCompra,
    precioVenta: precioVenta ?? this.precioVenta,
    stock: stock ?? this.stock,
    stockMinimo: stockMinimo ?? this.stockMinimo,
    unidad: unidad ?? this.unidad,
    activo: activo ?? this.activo,
    createdAt: createdAt,
  );
}