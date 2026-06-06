import 'package:flutter/material.dart';
import '../../inventory/services/email_service.dart';
import '../../../data/database/database_helper.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _codigoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _loading = false;
  bool _showPass = false;
  String? _error;

  Future<void> _resetear() async {
    final codigo = _codigoCtrl.text.trim();
    final pass = _passCtrl.text;
    final confirm = _confirmCtrl.text;

    if (codigo.isEmpty || pass.isEmpty || confirm.isEmpty) {
      setState(() => _error = 'Completa todos los campos');
      return;
    }
    if (pass != confirm) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Mínimo 6 caracteres');
      return;
    }
    if (!EmailService.verificarCodigo(widget.email, codigo)) {
      setState(() => _error = 'Código incorrecto o expirado');
      return;
    }

    setState(() { _loading = true; _error = null; });

    // Actualizar contraseña en SQLite
    final db = await DatabaseHelper.instance.database;
    final user = await DatabaseHelper.instance.getUserByEmail(widget.email);
    if (user != null) {
      await db.update(
        'usuarios',
        {'password': pass},
        where: 'email = ?',
        whereArgs: [widget.email],
      );
    }

    EmailService.limpiarCodigo();

    if (!mounted) return;
    setState(() => _loading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Contraseña actualizada correctamente'),
        backgroundColor: Colors.green,
      ),
    );

    Navigator.popUntil(context, (route) => route.isFirst);
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
                child: const Icon(Icons.verified_user_outlined,
                    color: Colors.white, size: 36),
              ),
              const SizedBox(height: 20),
              const Text('Nueva contraseña',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Código enviado a ${widget.email}',
                  style: const TextStyle(color: Colors.grey),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              TextField(
                controller: _codigoCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Código de 6 dígitos',
                  prefixIcon: const Icon(Icons.pin_outlined),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _passCtrl,
                obscureText: !_showPass,
                decoration: InputDecoration(
                  hintText: 'Nueva contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_showPass
                        ? Icons.visibility_off
                        : Icons.visibility),
                    onPressed: () =>
                        setState(() => _showPass = !_showPass),
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _confirmCtrl,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Confirmar contraseña',
                  prefixIcon: const Icon(Icons.lock_outline),
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
                  onPressed: _loading ? null : _resetear,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Guardar contraseña',
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver',
                    style: TextStyle(color: Color(0xFF2563EB))),
              ),
            ],
          ),
        ),
      ),
    );
  }
}