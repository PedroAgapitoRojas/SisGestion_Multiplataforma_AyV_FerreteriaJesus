import 'package:flutter/material.dart';

class SuppliersView extends StatelessWidget {

  const SuppliersView({super.key});

  @override
  Widget build(BuildContext context) {

    return const Center(
      child: Text(
        'PROVEEDORES',
        style: TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}