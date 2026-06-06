import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class AuthHeader extends StatelessWidget {

  final String title;

  final String subtitle;

  final IconData icon;

  const AuthHeader({

    super.key,

    required this.title,

    required this.subtitle,

    required this.icon,
  });

  @override
  Widget build(BuildContext context) {

    return Column(

      children: [

        Container(

          width: 90,
          height: 90,

          decoration: BoxDecoration(

            color: const Color(0xFF1D4ED8),

            borderRadius: BorderRadius.circular(26),
          ),

          child: Icon(

            icon,

            color: AppColors.white,

            size: 45,
          ),
        ),

        const SizedBox(height: 24),

        Text(

          title,

          style: const TextStyle(

            color: AppColors.white,

            fontSize: 34,

            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 10),

        Text(

          subtitle,

          textAlign: TextAlign.center,

          style: const TextStyle(

            color: AppColors.gray,

            fontSize: 16,
          ),
        ),
      ],
    );
  }
}