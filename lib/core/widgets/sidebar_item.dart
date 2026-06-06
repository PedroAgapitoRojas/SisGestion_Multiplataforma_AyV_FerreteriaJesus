import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class SidebarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.title,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        leading: Icon(
          icon,
          color: selected ? AppColors.yellow : AppColors.gray,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: selected ? AppColors.white : AppColors.gray,
            fontSize: 13,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        selected: selected,
        selectedTileColor: AppColors.charcoal,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        dense: true,
        onTap: onTap,
      ),
    );
  }
}