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

    return InkWell(

      onTap: onTap,

      borderRadius: BorderRadius.circular(14),

      child: Container(

        margin: const EdgeInsets.symmetric(
          vertical: 6,
        ),

        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 14,
        ),

        decoration: BoxDecoration(

          color: selected
              ? AppColors.yellow
              : Colors.transparent,

          borderRadius: BorderRadius.circular(14),
        ),

        child: Row(

          children: [

            Icon(

              icon,

              color: selected
                  ? AppColors.navy
                  : AppColors.lightGray,
            ),

            const SizedBox(width: 14),

            Expanded(

              child: Text(

                title,

                style: TextStyle(

                  color: selected
                      ? AppColors.navy
                      : AppColors.lightGray,

                  fontSize: 15,

                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}