import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class MainShellScreen extends StatelessWidget {
  final Widget child;
  const MainShellScreen({super.key, required this.child});

  int _getIndex(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    if (loc.startsWith('/dashboard')) return 0;
    if (loc.startsWith('/statistics')) return 1;
    if (loc.startsWith('/goals')) return 2;
    if (loc.startsWith('/history')) return 3;
    if (loc.startsWith('/settings')) return 4;
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _getIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSurface,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05))),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(context, Icons.dashboard_rounded, 'Home', 0, index),
                _navItem(context, Icons.bar_chart_rounded, 'Stats', 1, index),
                _navItem(context, Icons.flag_rounded, 'Metas', 2, index),
                _navItem(context, Icons.history_rounded, 'Histórico', 3, index),
                _navItem(context, Icons.settings_rounded, 'Config', 4, index),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, int idx, int current) {
    final selected = idx == current;
    final routes = ['/dashboard', '/statistics', '/goals', '/history', '/settings'];

    return GestureDetector(
      onTap: () => context.go(routes[idx]),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 24, color: selected ? AppColors.primary : AppColors.textTertiary),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w600 : FontWeight.w400, color: selected ? AppColors.primary : AppColors.textTertiary)),
        ]),
      ),
    );
  }
}
