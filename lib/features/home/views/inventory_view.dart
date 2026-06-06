import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../inventory/models/producto.dart';
import '../../inventory/services/inventory_service.dart';

class InventoryView extends StatefulWidget {
  const InventoryView({super.key});

  @override
  State<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends State<InventoryView> {
  final _service    = InventoryService();
  final _searchCtrl = TextEditingController();
  final _fmt = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ', decimalDigits: 2);
  List<Producto> _productos = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar({String? query}) async {
    setState(() => _loading = true);
    final p = await _service.getAll(query: query);
    if (mounted) setState(() { _productos = p; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text('Inventario',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const Spacer(),
            FilledButton.icon(
              onPressed: () => _abrirFormulario(),
              icon: const Icon(Icons.add),
              label: const Text('Nuevo Producto'),
              style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
            ),
          ],
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _searchCtrl,
          decoration: InputDecoration(
            hintText: 'Buscar por nombre, código o categoría...',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            suffixIcon: _searchCtrl.text.isNotEmpty
                ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchCtrl.clear();
                _cargar();
              },
            )
                : null,
          ),
          onChanged: (v) => _cargar(query: v.isEmpty ? null : v),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _productos.isEmpty
              ? const Center(
              child: Text('No se encontraron productos',
                  style: TextStyle(color: AppColors.gray)))
              : Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListView.separated(
              itemCount: _productos.length,
              separatorBuilder: (_, __) =>
              const Divider(height: 1),
              itemBuilder: (_, i) {
                final p = _productos[i];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: p.stockBajo
                        ? AppColors.error.withOpacity(0.15)
                        : AppColors.navy.withOpacity(0.1),
                    child: Icon(
                      Icons.inventory_2_outlined,
                      color: p.stockBajo
                          ? AppColors.error
                          : AppColors.navy,
                      size: 20,
                    ),
                  ),
                  title: Text(p.nombre,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${p.codigo} · ${p.categoria} · '
                        'Stock: ${p.stock} ${p.unidad}'
                        '${p.stockBajo ? ' ⚠ Stock bajo' : ''}',
                    style: TextStyle(
                      color: p.stockBajo
                          ? AppColors.error
                          : AppColors.gray,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_fmt.format(p.precioVenta),
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.navy)),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined,
                            size: 18),
                        onPressed: () =>
                            _abrirFormulario(producto: p),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            size: 18, color: AppColors.error),
                        onPressed: () => _eliminar(p),
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

  void _abrirFormulario({Producto? producto}) {
    showDialog(
      context: context,
      builder: (_) =>
          _ProductoDialog(producto: producto, service: _service),
    ).then((_) => _cargar(
        query: _searchCtrl.text.isEmpty ? null : _searchCtrl.text));
  }

  Future<void> _eliminar(Producto p) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar Producto'),
        content: Text('¿Eliminar "${p.nombre}"?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              style: FilledButton.styleFrom(
                  backgroundColor: AppColors.error),
              child: const Text('Eliminar')),
        ],
      ),
    );
    if (confirm == true) {
      await _service.delete(p.id!);
      _cargar();
    }
  }
}

// ── Diálogo formulario ──────────────────────────────────────────────────────

class _ProductoDialog extends StatefulWidget {
  final Producto? producto;
  final InventoryService service;
  const _ProductoDialog({this.producto, required this.service});

  @override
  State<_ProductoDialog> createState() => _ProductoDialogState();
}

class _ProductoDialogState extends State<_ProductoDialog> {
  final _formKey     = GlobalKey<FormState>();
  late final _nombre = TextEditingController(text: widget.producto?.nombre);
  late final _codigo = TextEditingController(text: widget.producto?.codigo);
  late final _cat    = TextEditingController(text: widget.producto?.categoria);
  late final _pc     = TextEditingController(
      text: widget.producto?.precioCompra.toString() ?? '0');
  late final _pv     = TextEditingController(
      text: widget.producto?.precioVenta.toString() ?? '0');
  late final _stock  = TextEditingController(
      text: widget.producto?.stock.toString() ?? '0');
  late final _sMin   = TextEditingController(
      text: (widget.producto?.stockMinimo ?? 5).toString());
  late final _unidad = TextEditingController(
      text: widget.producto?.unidad ?? 'unidad');
  bool _loading = false;

  @override
  void dispose() {
    for (final c in [_nombre,_codigo,_cat,_pc,_pv,_stock,_sMin,_unidad]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final p = Producto(
      id:            widget.producto?.id,
      nombre:        _nombre.text.trim(),
      codigo:        _codigo.text.trim().toUpperCase(),
      categoria:     _cat.text.trim(),
      precioCompra:  double.tryParse(_pc.text) ?? 0,
      precioVenta:   double.tryParse(_pv.text) ?? 0,
      stock:         int.tryParse(_stock.text) ?? 0,
      stockMinimo:   int.tryParse(_sMin.text) ?? 5,
      unidad:        _unidad.text.trim(),
    );
    try {
      if (widget.producto == null) {
        await widget.service.create(p);
      } else {
        await widget.service.update(p);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.producto == null
          ? 'Nuevo Producto'
          : 'Editar Producto'),
      content: SizedBox(
        width: 480,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _campo(_nombre, 'Nombre', required: true),
                _campo(_codigo, 'Código (ej: HER-001)', required: true),
                _campo(_cat, 'Categoría', required: true),
                Row(children: [
                  Expanded(child: _campo(_pc, 'Precio Compra', isNum: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _campo(_pv, 'Precio Venta',
                      isNum: true, required: true)),
                ]),
                Row(children: [
                  Expanded(child: _campo(_stock, 'Stock',
                      isInt: true, required: true)),
                  const SizedBox(width: 12),
                  Expanded(child: _campo(_sMin, 'Stock Mínimo', isInt: true)),
                ]),
                _campo(_unidad, 'Unidad (unidad, kg, bolsa…)'),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')),
        FilledButton(
            onPressed: _loading ? null : _guardar,
            style: FilledButton.styleFrom(backgroundColor: AppColors.navy),
            child: Text(
                widget.producto == null ? 'Crear' : 'Guardar')),
      ],
    );
  }

  Widget _campo(
      TextEditingController ctrl,
      String label, {
        bool required = false,
        bool isNum = false,
        bool isInt = false,
      }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextFormField(
          controller: ctrl,
          keyboardType: isNum || isInt
              ? TextInputType.number
              : TextInputType.text,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: AppColors.lightGray,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
          ),
          validator: (v) {
            if (required && (v == null || v.isEmpty)) return 'Requerido';
            if (isNum && v != null && v.isNotEmpty &&
                double.tryParse(v) == null) return 'Número inválido';
            if (isInt && v != null && v.isNotEmpty &&
                int.tryParse(v) == null) return 'Entero inválido';
            return null;
          },
        ),
      );
}