import 'package:flutter/material.dart';

class AuthInput extends StatelessWidget {

  final TextEditingController controller;
  final String label;
  final IconData icon;

  final bool obscureText;

  final Widget? suffixIcon;

  final TextInputType keyboardType;

  final String? Function(String?)? validator;

  const AuthInput({

    super.key,

    required this.controller,
    required this.label,
    required this.icon,

    this.obscureText = false,

    this.suffixIcon,

    this.keyboardType = TextInputType.text,

    this.validator,
  });

  @override
  Widget build(BuildContext context) {

    return TextFormField(

      controller: controller,

      obscureText: obscureText,

      keyboardType: keyboardType,

      validator: validator ??
              (value) {

            if (value == null || value.trim().isEmpty) {
              return 'Campo requerido';
            }

            return null;
          },

      decoration: InputDecoration(

        labelText: label,

        prefixIcon: Icon(
          icon,
          color: const Color(0xFF0D47A1),
        ),

        suffixIcon: suffixIcon,

        filled: true,

        fillColor: Colors.grey.shade100,

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: Colors.grey.shade300,
          ),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: Color(0xFFF4B400),
            width: 2,
          ),
        ),

        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 16,
        ),
      ),
    );
  }
}