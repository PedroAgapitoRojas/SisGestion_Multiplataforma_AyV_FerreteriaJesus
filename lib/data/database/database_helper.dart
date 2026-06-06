import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('ferreteria_jesus.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  // ← MÉTODO AGREGADO
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    final result = await db.query(
      'usuarios',
      where: 'email = ?',
      whereArgs: [email],
    );
    return result.isNotEmpty ? result.first : null;
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuarios (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        rol TEXT NOT NULL DEFAULT 'vendedor',
        activo INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE productos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        codigo TEXT NOT NULL UNIQUE,
        categoria TEXT NOT NULL,
        precio_compra REAL NOT NULL DEFAULT 0,
        precio_venta REAL NOT NULL DEFAULT 0,
        stock INTEGER NOT NULL DEFAULT 0,
        stock_minimo INTEGER NOT NULL DEFAULT 5,
        unidad TEXT NOT NULL DEFAULT 'unidad',
        activo INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        usuario_id INTEGER NOT NULL,
        total REAL NOT NULL DEFAULT 0,
        metodo_pago TEXT NOT NULL DEFAULT 'efectivo',
        estado TEXT NOT NULL DEFAULT 'completada',
        observacion TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (usuario_id) REFERENCES usuarios(id)
      )
    ''');
    await db.execute('''
      CREATE TABLE detalle_ventas (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        venta_id INTEGER NOT NULL,
        producto_id INTEGER NOT NULL,
        cantidad INTEGER NOT NULL DEFAULT 1,
        precio_unitario REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (venta_id) REFERENCES ventas(id),
        FOREIGN KEY (producto_id) REFERENCES productos(id)
      )
    ''');

    await db.insert('usuarios', {
      'nombre': 'Administrador',
      'email': 'admin@ferreteria.com',
      'password': 'admin123',
      'rol': 'admin',
      'activo': 1,
      'created_at': DateTime.now().toIso8601String(),
    });
    await db.insert('usuarios', {
      'nombre': 'Vendedor Demo',
      'email': 'vendedor@ferreteria.com',
      'password': 'vendedor123',
      'rol': 'vendedor',
      'activo': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    final now = DateTime.now().toIso8601String();
    final productos = [
      {'nombre':'Martillo 16oz','codigo':'HER-001','categoria':'Herramientas','precio_compra':15.0,'precio_venta':25.0,'stock':20,'stock_minimo':5,'unidad':'unidad','activo':1,'created_at':now},
      {'nombre':'Destornillador Estrella 6"','codigo':'HER-002','categoria':'Herramientas','precio_compra':5.0,'precio_venta':9.0,'stock':3,'stock_minimo':5,'unidad':'unidad','activo':1,'created_at':now},
      {'nombre':'Cemento Portland 42.5kg','codigo':'MAT-001','categoria':'Materiales','precio_compra':28.0,'precio_venta':35.0,'stock':50,'stock_minimo':10,'unidad':'bolsa','activo':1,'created_at':now},
      {'nombre':'Pintura Látex Blanco 4L','codigo':'PIN-001','categoria':'Pinturas','precio_compra':35.0,'precio_venta':52.0,'stock':12,'stock_minimo':3,'unidad':'galón','activo':1,'created_at':now},
      {'nombre':'Clavos 2" x kg','codigo':'FER-001','categoria':'Ferretería','precio_compra':3.0,'precio_venta':5.5,'stock':4,'stock_minimo':5,'unidad':'kg','activo':1,'created_at':now},
      {'nombre':'Llave Francesa 10"','codigo':'HER-003','categoria':'Herramientas','precio_compra':12.0,'precio_venta':20.0,'stock':8,'stock_minimo':3,'unidad':'unidad','activo':1,'created_at':now},
      {'nombre':'Tubo PVC 4" x 3m','codigo':'PLO-001','categoria':'Plomería','precio_compra':18.0,'precio_venta':28.0,'stock':15,'stock_minimo':5,'unidad':'unidad','activo':1,'created_at':now},
    ];
    for (final p in productos) {
      await db.insert('productos', p);
    }
  }
}