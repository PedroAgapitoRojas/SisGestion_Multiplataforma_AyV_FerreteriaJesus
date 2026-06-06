import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../inventory/services/sales_service.dart';

class ReportsView extends StatefulWidget {
  const ReportsView({super.key});

  @override
  State<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends State<ReportsView> {
  final _service = SalesService();
  final _fmt = NumberFormat.currency(
      locale: 'es_PE', symbol: 'S/ ', decimalDigits: 2);

  Map<String, double> _ventasPorDia      = {};
  Map<String, double> _ventasPorMetodo   = {};
  List<Map<String, dynamic>> _ventas     = [];
  bool _loading                          = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    setState(() => _loading = true);
    final dias   = await _service.getVentasPorDia(dias: 7);
    final metodo = await _service.getVentasPorMetodoPago();
    final ventas = await _service.getVentas();
    if (mounted) {
      setState(() {
        _ventasPorDia    = dias;
        _ventasPorMetodo = metodo;
        _ventas          = ventas;
        _loading         = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Center(child: CircularProgressIndicator());

    final totalGeneral =
    _ventas.fold<double>(0, (s, v) => s + (v['total'] as num).toDouble());

    return ListView(
      children: [
        const Text('Reportes',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),

        // Resumen por método de pago
        const Text('Ventas por método de pago (mes actual)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 12),
        Row(
          children: _ventasPorMetodo.entries.map((e) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: e.key == 'efectivo'
                      ? AppColors.navy
                      : const Color(0xFF7C3AED),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      e.key == 'efectivo'
                          ? Icons.money
                          : Icons.phone_android,
                      color: Colors.white70,
                    ),
                    const SizedBox(height: 8),
                    Text(_fmt.format(e.value),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold)),
                    Text(e.key.toUpperCase(),
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 12)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        const SizedBox(height: 24),

        // Ventas últimos 7 días (barras simples)
        const Text('Ventas últimos 7 días',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: _ventasPorDia.entries.map((e) {
              final maxVal = _ventasPorDia.values
                  .fold<double>(0, (m, v) => v > m ? v : m);
              final pct = maxVal > 0 ? e.value / maxVal : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(children: [
                  SizedBox(
                      width: 50,
                      child: Text(e.key,
                          style:
                          const TextStyle(fontSize: 12))),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Stack(children: [
                      Container(
                        height: 20,
                        decoration: BoxDecoration(
                          color: AppColors.lightGray,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      FractionallySizedBox(
                        widthFactor: pct.toDouble(),
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: AppColors.navy,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ]),
                  ),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 80,
                    child: Text(
                      _fmt.format(e.value),
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ]),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 24),

        // Historial de ventas
        Row(
          children: [
            const Text('Historial de Ventas',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 15)),
            const Spacer(),
            Text('Total: ${_fmt.format(totalGeneral)}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.navy)),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: _ventas.isEmpty
              ? const Padding(
            padding: EdgeInsets.all(24),
            child: Center(
                child: Text('Sin ventas registradas',
                    style: TextStyle(color: AppColors.gray))),
          )
              : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _ventas.length,
            separatorBuilder: (_, __) =>
            const Divider(height: 1),
            itemBuilder: (_, i) {
              final v = _ventas[i];
              final fecha = DateTime.parse(v['created_at']);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: v['metodo_pago'] == 'efectivo'
                      ? AppColors.navy.withOpacity(0.1)
                      : const Color(0xFF7C3AED).withOpacity(0.1),
                  child: Icon(
                    v['metodo_pago'] == 'efectivo'
                        ? Icons.money
                        : Icons.phone_android,
                    color: v['metodo_pago'] == 'efectivo'
                        ? AppColors.navy
                        : const Color(0xFF7C3AED),
                    size: 18,
                  ),
                ),
                title: Text(
                  _fmt.format((v['total'] as num).toDouble()),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  '${v['vendedor']} · '
                      '${DateFormat('dd/MM/yyyy HH:mm').format(fecha)}',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Chip(
                  label: Text(
                    (v['metodo_pago'] as String).toUpperCase(),
                    style: const TextStyle(
                        fontSize: 10, color: Colors.white),
                  ),
                  backgroundColor:
                  v['metodo_pago'] == 'efectivo'
                      ? AppColors.navy
                      : const Color(0xFF7C3AED),
                  padding: EdgeInsets.zero,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}