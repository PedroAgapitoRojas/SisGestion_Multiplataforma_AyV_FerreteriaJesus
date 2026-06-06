import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../models/menu_item_model.dart';
import '../views/inventory_view.dart';
import '../views/pos_view.dart';
import '../views/reports_view.dart';
import '../views/settings_view.dart';
import '../views/users_view.dart';
import '../widgets/dashboard_view.dart';
import '../widgets/sidebar.dart';
import '../../auth/screens/login_screen.dart';

class HomeScreen extends StatefulWidget {
  final Map<String, dynamic> usuario;
  const HomeScreen({super.key, required this.usuario});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;
  late final List<MenuItemModel> menuItems;

  @override
  void initState() {
    super.initState();
    final isAdmin = widget.usuario['rol'] == 'admin';
    menuItems = [
      MenuItemModel(
        title: 'Dashboard',
        icon: Icons.dashboard_outlined,
        screen: DashboardView(usuario: widget.usuario),
      ),
      MenuItemModel(
        title: 'Ventas POS',
        icon: Icons.point_of_sale,
        screen: PosView(usuario: widget.usuario),
      ),
      MenuItemModel(
        title: 'Inventario',
        icon: Icons.inventory_2_outlined,
        screen: const InventoryView(),
      ),
      MenuItemModel(
        title: 'Reportes',
        icon: Icons.bar_chart_outlined,
        screen: const ReportsView(),
      ),
      if (isAdmin)
        MenuItemModel(
          title: 'Usuarios',
          icon: Icons.people_alt_outlined,
          screen: const UsersView(),
        ),
      MenuItemModel(
        title: 'Ajustes',
        icon: Icons.settings_outlined,
        screen: SettingsView(usuario: widget.usuario),
      ),
    ];
  }

  void _logout() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Scaffold(
      backgroundColor: AppColors.lightGray,
      drawer: isMobile
          ? Drawer(
        child: Sidebar(
          selectedIndex: selectedIndex,
          items: menuItems,
          usuario: widget.usuario,
          onSelected: (i) {
            setState(() => selectedIndex = i);
            Navigator.pop(context);
          },
          onLogout: _logout,
        ),
      )
          : null,
      appBar: isMobile
          ? AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: AppColors.white,
        title: Text(menuItems[selectedIndex].title),
      )
          : null,
      body: isMobile
          ? Padding(
        padding: const EdgeInsets.all(16),
        child: menuItems[selectedIndex].screen,
      )
          : Row(
        children: [
          Sidebar(
            selectedIndex: selectedIndex,
            items: menuItems,
            usuario: widget.usuario,
            onSelected: (i) => setState(() => selectedIndex = i),
            onLogout: _logout,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: menuItems[selectedIndex].screen,
            ),
          ),
        ],
      ),
    );
  }
}