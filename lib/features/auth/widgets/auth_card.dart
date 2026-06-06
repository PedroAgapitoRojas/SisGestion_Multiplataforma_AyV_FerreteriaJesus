import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

class AuthCard extends StatelessWidget {
  final Widget child;

  const AuthCard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(30),

      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(24),

        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),

      child: child,
    );
  }
}