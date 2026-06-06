import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/menu_item_model.dart';
import 'sidebar_item.dart';

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final List<MenuItemModel> items;
  final Map<String, dynamic> usuario;
  final Function(int) onSelected;
  final VoidCallback onLogout;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.items,
    required this.usuario,
    required this.onSelected,
    required this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: AppColors.navy,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.hardware, color: AppColors.yellow, size: 36),
          const SizedBox(height: 6),
          const Text(
            'FERRETERÍA JESÚS',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 20),
          // Info del usuario logueado
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.charcoal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.yellow,
                  child: Icon(Icons.person, color: AppColors.navy, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usuario['nombre'] ?? 'Usuario',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        (usuario['rol'] ?? '').toString().toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.yellow,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'MENÚ',
            style: TextStyle(
              color: AppColors.gray,
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) => SidebarItem(
                title: items[index].title,
                icon: items[index].icon,
                selected: selectedIndex == index,
                onTap: () => onSelected(index),
              ),
            ),
          ),
          const Divider(color: AppColors.charcoal),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error, size: 20),
            title: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: AppColors.error, fontSize: 13),
            ),
            onTap: onLogout,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            dense: true,
          ),
        ],
      ),
    );
  }
}