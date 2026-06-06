import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';

class EmailService {
  static const _gmailUser = 'aloyolamendoza6@gmail.com';     // ← tu Gmail
  static const _gmailPass = 'jshw qsro qpqx wzpp';      // ← contraseña de app

  static String _generarCodigo() {
    final rand = DateTime.now().millisecondsSinceEpoch % 1000000;
    return rand.toString().padLeft(6, '0');
  }

  static String? _codigoActual;
  static String? _emailDestino;
  static DateTime? _expiracion;

  static Future<String?> enviarCodigoRecuperacion(String email) async {
    try {
      final codigo = _generarCodigo();
      _codigoActual = codigo;
      _emailDestino = email;
      _expiracion = DateTime.now().add(const Duration(minutes: 10));

      final smtpServer = gmail(_gmailUser, _gmailPass);
      final message = Message()
        ..from = Address(_gmailUser, 'Ferretería Jesús')
        ..recipients.add(email)
        ..subject = 'Código de recuperación de contraseña'
        ..html = '''
          <div style="font-family: Arial; padding: 20px;">
            <h2 style="color: #0f172a;">Ferretería Jesús</h2>
            <p>Tu código de recuperación es:</p>
            <h1 style="color: #2563EB; letter-spacing: 8px;">$codigo</h1>
            <p style="color: gray;">Este código expira en 10 minutos.</p>
          </div>
        ''';

      await send(message, smtpServer);
      return null; // null = éxito
    } catch (e) {
      return 'Error al enviar el correo: $e';
    }
  }

  static bool verificarCodigo(String email, String codigo) {
    if (_codigoActual == null || _emailDestino == null || _expiracion == null) {
      return false;
    }
    if (DateTime.now().isAfter(_expiracion!)) return false;
    return _emailDestino == email && _codigoActual == codigo;
  }

  static void limpiarCodigo() {
    _codigoActual = null;
    _emailDestino = null;
    _expiracion = null;
  }
}