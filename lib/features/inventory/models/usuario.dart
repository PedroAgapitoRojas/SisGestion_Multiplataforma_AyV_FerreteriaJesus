class Usuario {
  final int? id;
  final String nombre;
  final String email;
  final String password;
  final String rol;
  final bool activo;
  final String createdAt;

  Usuario({
    this.id,
    required this.nombre,
    required this.email,
    required this.password,
    this.rol = 'vendedor',
    this.activo = true,
    String? createdAt,
  }) : createdAt = createdAt ?? DateTime.now().toIso8601String();

  Map<String, dynamic> toMap() => {
    'id': id,
    'nombre': nombre,
    'email': email,
    'password': password,
    'rol': rol,
    'activo': activo ? 1 : 0,
    'created_at': createdAt,
  };

  factory Usuario.fromMap(Map<String, dynamic> m) => Usuario(
    id: m['id'],
    nombre: m['nombre'],
    email: m['email'],
    password: m['password'],
    rol: m['rol'],
    activo: m['activo'] == 1,
    createdAt: m['created_at'],
  );
}