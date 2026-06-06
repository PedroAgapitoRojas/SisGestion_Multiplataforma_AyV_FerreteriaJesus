import 'package:flutter/material.dart';
import '../../home/screens/home_screen.dart';
import '../services/auth_service.dart';
import 'forgot_password_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey         = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passController  = TextEditingController();
  final _authService     = AuthService();
  bool _loading          = false;
  bool _obscurePassword  = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final user = await _authService.login(
        email: _emailController.text,
        password: _passController.text,
      );
      if (!mounted) return;
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(usuario: user)),
        );
      } else {
        _showError('Correo o contraseña incorrectos');
      }
    } catch (e) {
      _showError('Error al iniciar sesión: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 800;
    return Scaffold(
      body: isMobile ? _buildMobile() : _buildDesktop(),
    );
  }

  // ─── DESKTOP ─────────────────────────────────────────
  Widget _buildDesktop() {
    return Row(
      children: [
        // Lado izquierdo oscuro
        Expanded(
          child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF0F172A), Color(0xFF1E3A5F)],
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFACC15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(Icons.hardware,
                      color: Color(0xFF0F172A), size: 36),
                ),
                const SizedBox(height: 24),
                const Text(
                  'FERRETERÍA JESÚS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Sistema inteligente de gestión de\nventas, inventario y administración.',
                  style: TextStyle(color: Colors.white60, fontSize: 15),
                ),
                const SizedBox(height: 40),
                _FeatureItem(
                    icon: Icons.point_of_sale,
                    text: 'Ventas POS rápidas y modernas'),
                const SizedBox(height: 16),
                _FeatureItem(
                    icon: Icons.inventory_2_outlined,
                    text: 'Control de inventario en tiempo real'),
                const SizedBox(height: 16),
                _FeatureItem(
                    icon: Icons.bar_chart,
                    text: 'Reportes y estadísticas'),
              ],
            ),
          ),
        ),
        // Lado derecho blanco
        Container(
          width: 420,
          color: Colors.white,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(48),
              child: _buildForm(),
            ),
          ),
        ),
      ],
    );
  }

  // ─── MOBILE ──────────────────────────────────────────
  Widget _buildMobile() {
    return Container(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _buildForm(),
        ),
      ),
    );
  }

  // ─── FORMULARIO ──────────────────────────────────────
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.lock_outline,
                color: Colors.white, size: 36),
          ),
          const SizedBox(height: 20),
          const Text(
            'Bienvenido',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Ingresa tus credenciales para continuar',
            style: TextStyle(color: Colors.grey, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDeco('Correo electrónico', Icons.email_outlined),
            validator: (v) =>
            v == null || v.isEmpty ? 'Ingrese su correo' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passController,
            obscureText: _obscurePassword,
            decoration: _inputDeco('Contraseña', Icons.lock_outline).copyWith(
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
            ),
            validator: (v) =>
            v == null || v.isEmpty ? 'Ingrese su contraseña' : null,
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const ForgotPasswordScreen()),
              ),
              child: const Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(color: Color(0xFF2563EB), fontSize: 13),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _loading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                'Iniciar sesión',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDeco(String hint, IconData icon) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Colors.grey),
    prefixIcon: Icon(icon, color: Colors.grey),
    filled: true,
    fillColor: const Color(0xFFF1F5F9),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide:
      const BorderSide(color: Color(0xFF2563EB), width: 2),
    ),
  );
}

// ─── Widget feature item ─────────────────────────────
class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _FeatureItem({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFFACC15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF0F172A), size: 20),
        ),
        const SizedBox(width: 16),
        Text(text,
            style: const TextStyle(color: Colors.white, fontSize: 15)),
      ],
    );
  }
}