import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../auth/screens/login_screen.dart';

class SettingsView extends StatelessWidget {
  final Map<String, dynamic> usuario;
  const SettingsView({super.key, required this.usuario});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        const Text('Ajustes',
            style: TextStyle(
                fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 24),
        // Información del sistema
        _seccion('Sistema', [
          _item(Icons.store, 'Empresa', 'Ferretería Jesús'),
          _item(Icons.location_on_outlined, 'Dirección',
              'Chincha, Ica, Perú'),
          _item(Icons.info_outline, 'Versión', '1.0.0'),
          _item(Icons.storage_outlined, 'Base de datos', 'SQLite local'),
        ]),
        const SizedBox(height: 16),
        // Información del usuario
        _seccion('Mi Cuenta', [
          _item(Icons.person_outline, 'Nombre',
              usuario['nombre'] ?? ''),
          _item(Icons.email_outlined, 'Correo',
              usuario['email'] ?? ''),
          _item(Icons.badge_outlined, 'Rol',
              (usuario['rol'] ?? '').toString().toUpperCase()),
        ]),
        const SizedBox(height: 24),
        // Cerrar sesión
        SizedBox(
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (_) => const LoginScreen()),
                    (route) => false,
              );
            },
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: const Text('Cerrar Sesión',
                style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _seccion(String titulo, List<Widget> items) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
          child: Text(titulo,
              style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppColors.gray,
                  fontSize: 12,
                  letterSpacing: 1)),
        ),
        const Divider(height: 1),
        ...items,
      ],
    ),
  );

  Widget _item(IconData icon, String label, String value) => ListTile(
    leading: Icon(icon, color: AppColors.navy, size: 20),
    title: Text(label,
        style: const TextStyle(fontSize: 13, color: AppColors.gray)),
    trailing: Text(value,
        style: const TextStyle(
            fontWeight: FontWeight.w600, fontSize: 13)),
    dense: true,
  );
}