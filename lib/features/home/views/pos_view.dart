import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../inventory/models/producto.dart';
import '../../inventory/services/inventory_service.dart';
import '../../inventory/models/venta.dart';
import '../../inventory/services/sales_service.dart';

class PosView extends StatefulWidget {
  final Map<String, dynamic> usuario;
  const PosView({super.key, required this.usuario});

  @override
  State<PosView> createState() => _PosViewState();
}

class _PosViewState extends State<PosView> {
  final _inventoryService = InventoryService();
  final _salesService     = SalesService();
  final _searchCtrl       = TextEditingController();
  final _fmt = NumberFormat.currency(
      locale: 'es_PE', symbol: 'S/ ', decimalDigits: 2);

  List<Producto> _productos  = [];
  List<ItemCarrito> _carrito = [];
  String _metodoPago         = 'efectivo';
  bool _loading              = false;

  @override
  void initState() {
    super.initState();
    _cargarProductos();
  }

  Future<void> _cargarProductos({String? query}) async {
    final p = await _inventoryService.getAll(query: query);
    if (mounted) {
      setState(() => _productos = p.where((x) => x.stock > 0).toList());
    }
  }

  void _agregar(Producto p) {
    setState(() {
      final idx = _carrito.indexWhere((i) => i.producto.id == p.id);
      if (idx >= 0) {
        if (_carrito[idx].cantidad < p.stock) _carrito[idx].cantidad++;
      } else {
        _carrito.add(ItemCarrito(producto: p));
      }
    });
  }

  void _cambiarCantidad(int idx, int delta) {
    setState(() {
      final nueva = _carrito[idx].cantidad + delta;
      if (nueva <= 0) {
        _carrito.removeAt(idx);
      } else if (nueva <= _carrito[idx].producto.stock) {
        _carrito[idx].cantidad = nueva;
      }
    });
  }

  double get _total =>
      _carrito.fold(0, (s, i) => s + i.subtotal);

  Future<void> _cobrar() async {
    if (_carrito.isEmpty) return;
    setState(() => _loading = true);
    try {
      await _salesService.registrarVenta(
        usuarioId: widget.usuario['id'],
        carrito: _carrito,
        metodoPago: _metodoPago,
      );
      _mostrarExito();
      setState(() {
        _carrito.clear();
        _metodoPago = 'efectivo';
      });
      _cargarProductos();
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

  void _mostrarExito() {
    final totalCobrado = _total;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        icon: const Icon(Icons.check_circle,
            color: AppColors.success, size: 52),
        title: const Text('¡Venta Registrada!',
            textAlign: TextAlign.center),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total: ${_fmt.format(totalCobrado)}',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text('Método: ${_metodoPago.toUpperCase()}'),
            Text(DateFormat('dd/MM/yyyy HH:mm')
                .format(DateTime.now())),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.success),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width > 700;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Punto de Venta',
            style:
            TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Expanded(
          child: isWide
              ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: _catalogo()),
              const SizedBox(width: 20),
              SizedBox(width: 300, child: _carritoPannel()),
            ],
          )
              : _carritoPannel(),
        ),
      ],
    );
  }

  Widget _catalogo() => Column(
    children: [
      TextField(
        controller: _searchCtrl,
        decoration: InputDecoration(
          hintText: 'Buscar producto...',
          prefixIcon: const Icon(Icons.search),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
        ),
        onChanged: (v) =>
            _cargarProductos(query: v.isEmpty ? null : v),
      ),
      const SizedBox(height: 12),
      Expanded(
        child: GridView.builder(
          gridDelegate:
          const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 180,
            mainAxisExtent: 100,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemCount: _productos.length,
          itemBuilder: (_, i) {
            final p = _productos[i];
            return GestureDetector(
              onTap: () => _agregar(p),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.lightGray),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    const Icon(Icons.inventory_2_outlined,
                        color: AppColors.navy, size: 20),
                    Text(p.nombre,
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                    Row(
                        mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                        children: [
                          Text(_fmt.format(p.precioVenta),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.navy,
                                  fontSize: 12)),
                          Text('${p.stock}',
                              style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.gray)),
                        ]),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    ],
  );

  Widget _carritoPannel() => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
    ),
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Carrito',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
        const Divider(),
        Expanded(
          child: _carrito.isEmpty
              ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined,
                    size: 48, color: AppColors.gray),
                SizedBox(height: 8),
                Text('Sin productos',
                    style:
                    TextStyle(color: AppColors.gray)),
              ],
            ),
          )
              : ListView.builder(
            itemCount: _carrito.length,
            itemBuilder: (_, i) {
              final item = _carrito[i];
              return Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          Text(item.producto.nombre,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight:
                                  FontWeight.w600),
                              overflow:
                              TextOverflow.ellipsis),
                          Text(
                              _fmt.format(
                                  item.producto.precioVenta),
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.gray)),
                        ],
                      ),
                    ),
                    Row(children: [
                      IconButton(
                          icon: const Icon(
                              Icons.remove_circle_outline,
                              size: 18),
                          onPressed: () =>
                              _cambiarCantidad(i, -1)),
                      Text('${item.cantidad}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      IconButton(
                          icon: const Icon(
                              Icons.add_circle_outline,
                              size: 18),
                          onPressed: () =>
                              _cambiarCantidad(i, 1)),
                    ]),
                  ],
                ),
              );
            },
          ),
        ),
        const Divider(),
        // Método de pago
        const Text('Método de pago:',
            style: TextStyle(
                fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        Row(children: [
          _botonPago('efectivo', Icons.money, 'Efectivo'),
          const SizedBox(width: 8),
          _botonPago('yape', Icons.phone_android, 'Yape'),
        ]),
        const SizedBox(height: 12),
        // Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('TOTAL:',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            Text(_fmt.format(_total),
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: FilledButton.icon(
            onPressed:
            (_carrito.isEmpty || _loading) ? null : _cobrar,
            icon: _loading
                ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2))
                : const Icon(Icons.point_of_sale),
            label: const Text('Cobrar',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            style: FilledButton.styleFrom(
                backgroundColor: AppColors.success),
          ),
        ),
      ],
    ),
  );

  Widget _botonPago(String valor, IconData icon, String label) {
    final sel = _metodoPago == valor;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _metodoPago = valor),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: sel ? AppColors.navy : AppColors.lightGray,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(children: [
            Icon(icon,
                color: sel ? Colors.white : AppColors.gray, size: 20),
            Text(label,
                style: TextStyle(
                    color: sel ? Colors.white : AppColors.gray,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}