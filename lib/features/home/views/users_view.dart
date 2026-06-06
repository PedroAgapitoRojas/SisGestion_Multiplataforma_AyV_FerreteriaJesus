import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../inventory/models/usuario.dart';
import '../../inventory/services/user_service.dart';

class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  final _service   = UserService();
  List<Usuario> _usuarios = [];
  bool _loading    = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    final u = await _service.getAll();
    if (mounted) setState(() { _usuarios = u; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Text('Usuarios',
              style: TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold)),
          const Spacer(),
          FilledButton.icon(
            onPressed: () => _abrirFormulario(),
            icon: const Icon(Icons.person_add),
            label: const Text('Nuevo Usuario'),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.navy),
          ),
        ]),
        const SizedBox(height: 16),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              itemCount: _usuarios.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1),
              itemBuilder: (_, i) {
                final u = _usuarios[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: u.rol == 'admin'
                        ? AppColors.yellow.withOpacity(0.2)
                        : AppColors.navy.withOpacity(0.1),
                    child: Icon(Icons.person,
                        color: u.rol == 'admin'
                            ? AppColors.yellowDark
                            : AppColors.navy,
                        size: 20),
                  ),
                  title: Text(u.nombre,
                      style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: u.activo
                              ? null
                              : AppColors.gray)),
                  subtitle: Text(
                    '${u.email} · ${u.rol.toUpperCase()}'
                        '${u.activo ? '' : ' · INACTIVO'}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: u.activo,
                        onChanged: (v) async {
                          await _service.toggleActivo(
                              u.id!, v);
                          _cargar();
                        },
                        activeColor: AppColors.success,
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            size: 18),
                        onPressed: () =>
                            _abrirFormulario(usuario: u),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  void _abrirFormulario({Usuario? usuario}) {
    showDialog(
      context: context,
      builder: (_) =>
          _UsuarioDialog(usuario: usuario, service: _service),
    ).then((_) => _cargar());
  }
}

class _UsuarioDialog extends StatefulWidget {
  final Usuario? usuario;
  final UserService service;
  const _UsuarioDialog({this.usuario, required this.service});

  @override
  State<_UsuarioDialog> createState() => _UsuarioDialogState();
}

class _UsuarioDialogState extends State<_UsuarioDialog> {
  final _formKey   = GlobalKey<FormState>();
  late final _nombre = TextEditingController(
      text: widget.usuario?.nombre);
  late final _email  = TextEditingController(
      text: widget.usuario?.email);
  late final _pass   = TextEditingController(
      text: widget.usuario?.password);
  String _rol        = 'vendedor';
  bool _loading      = false;

  @override
  void initState() {
    super.initState();
    _rol = widget.usuario?.rol ?? 'vendedor';
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final u = Usuario(
      id:       widget.usuario?.id,
      nombre:   _nombre.text.trim(),
      email:    _email.text.trim(),
      password: _pass.text,
      rol:      _rol,
      activo:   widget.usuario?.activo ?? true,
    );
    try {
      if (widget.usuario == null) {
        await widget.service.create(u);
      } else {
        await widget.service.update(u);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'),
              backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.usuario == null
          ? 'Nuevo Usuario'
          : 'Editar Usuario'),
      content: SizedBox(
        width: 400,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _campo(_nombre, 'Nombre completo', required: true),
              _campo(_email, 'Correo electrónico', required: true),
              _campo(_pass, 'Contraseña', required: true,
                  obscure: true),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _rol,
                decoration: InputDecoration(
                  labelText: 'Rol',
                  filled: true,
                  fillColor: AppColors.lightGray,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: const [
                  DropdownMenuItem(
                      value: 'admin', child: Text('Administrador')),
                  DropdownMenuItem(
                      value: 'vendedor', child: Text('Vendedor')),
                ],
                onChanged: (v) => setState(() => _rol = v!),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        FilledButton(
          onPressed: _loading ? null : _guardar,
          style: FilledButton.styleFrom(
              backgroundColor: AppColors.navy),
          child: Text(
              widget.usuario == null ? 'Crear' : 'Guardar'),
        ),
      ],
    );
  }

  Widget _campo(
      TextEditingController ctrl,
      String label, {
        bool required = false,
        bool obscure = false,
      }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: ctrl,
          obscureText: obscure,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: AppColors.lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (v) => required && (v == null || v.isEmpty)
              ? 'Campo requerido'
              : null,
        ),
      );
}