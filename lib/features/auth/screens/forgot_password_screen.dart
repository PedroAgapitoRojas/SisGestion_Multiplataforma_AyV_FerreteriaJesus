import 'package:flutter/material.dart';
import '../../inventory/services/email_service.dart';
import '../../../data/database/database_helper.dart';
import 'reset_password_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _enviar() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Ingresa tu correo');
      return;
    }

    setState(() { _loading = true; _error = null; });

    // Verificar que el email existe en la BD
    final user = await DatabaseHelper.instance.getUserByEmail(email);
    if (user == null) {
      setState(() {
        _error = 'No existe una cuenta con ese correo';
        _loading = false;
      });
      return;
    }

    final error = await EmailService.enviarCodigoRecuperacion(email);
    if (!mounted) return;

    if (error != null) {
      setState(() { _error = error; _loading = false; });
      return;
    }

    setState(() => _loading = false);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(email: email),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      body: Center(
        child: Container(
          width: 400,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.lock_reset, color: Colors.white, size: 36),
              ),
              const SizedBox(height: 20),
              const Text('Recuperar contraseña',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Te enviaremos un código de verificación',
                  style: TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  hintText: 'Correo electrónico',
                  prefixIcon: const Icon(Icons.email_outlined),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _enviar,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Enviar código',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver al login',
                    style: TextStyle(color: Color(0xFF2563EB))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}