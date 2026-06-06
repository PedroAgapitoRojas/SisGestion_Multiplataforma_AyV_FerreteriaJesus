import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../inventory/services/sales_service.dart';
import '../../inventory/services/inventory_service.dart';

class DashboardView extends StatefulWidget {
  final Map<String, dynamic> usuario;
  const DashboardView({super.key, required this.usuario});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  final _salesService     = SalesService();
  final _inventoryService = InventoryService();
  final _fmt = NumberFormat.currency(locale: 'es_PE', symbol: 'S/ ', decimalDigits: 2);

  double _ventasHoy    = 0;
  int _totalProductos  = 0;
  int _stockBajoCount  = 0;
  int _ventasCount     = 0;
  bool _loading        = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    final v  = await _salesService.getTotalVentasHoy();
    final vc = await _salesService.contarVentasHoy();
    final p  = await _inventoryService.getTotalProductos();
    final sb = await _inventoryService.getStockBajo();
    if (mounted) {
      setState(() {
        _ventasHoy      = v;
        _ventasCount    = vc;
        _totalProductos = p;
        _stockBajoCount = sb.length;
        _loading        = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    return RefreshIndicator(
      onRefresh: _cargarDatos,
      child: ListView(
        children: [
          // Encabezado
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Dashboard',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Bienvenido, ${widget.usuario['nombre']}',
                    style: const TextStyle(color: AppColors.gray),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                DateFormat('dd/MM/yyyy').format(DateTime.now()),
                style: const TextStyle(color: AppColors.gray),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Tarjetas
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 600 ? 4 : 2;
              return GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: cols,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
                children: [
                  _Tarjeta(
                    titulo: 'Ventas Hoy',
                    valor: _fmt.format(_ventasHoy),
                    icon: Icons.point_of_sale,
                    color: AppColors.navy,
                  ),
                  _Tarjeta(
                    titulo: 'Transacciones',
                    valor: '$_ventasCount ventas',
                    icon: Icons.receipt_long_outlined,
                    color: const Color(0xFF0369A1),
                  ),
                  _Tarjeta(
                    titulo: 'Productos',
                    valor: '$_totalProductos',
                    icon: Icons.inventory_2_outlined,
                    color: const Color(0xFF7C3AED),
                  ),
                  _Tarjeta(
                    titulo: 'Stock Bajo',
                    valor: '$_stockBajoCount ítems',
                    icon: Icons.warning_amber_outlined,
                    color: _stockBajoCount > 0
                        ? AppColors.warning
                        : AppColors.success,
                  ),
                ],
              );
            },
          ),

          // Alerta stock bajo
          if (_stockBajoCount > 0) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withOpacity(0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$_stockBajoCount producto(s) con stock bajo. '
                          'Revisa el módulo de Inventario.',
                      style: const TextStyle(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _Tarjeta extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icon;
  final Color color;

  const _Tarjeta({
    required this.titulo,
    required this.valor,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: Colors.white70, size: 26),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                valor,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                titulo,
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}