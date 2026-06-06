import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {

  final String text;

  final bool loading;

  final VoidCallback onPressed;

  const AuthButton({

    super.key,

    required this.text,

    required this.loading,

    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {

    return SizedBox(

      width: double.infinity,

      height: 55,

      child: ElevatedButton(

        onPressed: loading ? null : onPressed,

        style: ElevatedButton.styleFrom(

          backgroundColor: const Color(0xFF0D47A1),

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),

        child: loading

            ? const SizedBox(

          width: 24,
          height: 24,

          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )

            : Text(

          text,

          style: const TextStyle(

            color: Colors.white,

            fontSize: 16,

            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}