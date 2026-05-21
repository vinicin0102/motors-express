import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  double _totalRevenue = 0;
  double _netProfit = 0;
  int _totalRides = 0;
  double _totalKm = 0;
  double _fuelCost = 0;
  double _avgPerKm = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyStr = prefs.getString('ride_history');
      if (historyStr != null) {
        final List<dynamic> jsonList = jsonDecode(historyStr);
        for (var e in jsonList) {
          final r = e as Map<String, dynamic>;
          _totalRevenue += (r['value'] as num).toDouble();
          _totalKm += (r['distance'] as num).toDouble();
          _netProfit += (r['profit'] as num).toDouble();
          _totalRides++;
        }
        _fuelCost = _totalRevenue - _netProfit;
        if (_totalKm > 0) _avgPerKm = _totalRevenue / _totalKm;
      }
    } catch (e) {
      debugPrint('Error loading stats: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0E21), Color(0xFF141729)])),
        child: SafeArea(child: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('📊 Estatísticas', style: Theme.of(context).textTheme.displayMedium).animate().fadeIn(),
          const SizedBox(height: 8),
          Text('Seus números em detalhes (Hoje)', style: Theme.of(context).textTheme.bodyLarge).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 24),

          // Period selector
          Row(children: ['Hoje', 'Semana', 'Mês', 'Ano'].asMap().entries.map((e) => Expanded(child: GestureDetector(
            child: Container(
              margin: EdgeInsets.only(right: e.key < 3 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: e.key == 0 ? AppColors.primary : AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: e.key == 0 ? AppColors.primary : Colors.white.withOpacity(0.05)),
              ),
              child: Center(child: Text(e.value, style: TextStyle(fontWeight: e.key == 0 ? FontWeight.w700 : FontWeight.w400, fontSize: 13, color: e.key == 0 ? Colors.white : AppColors.textSecondary))),
            ),
          ))).toList()).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          // Stats grid
          _statRow('Receita total', 'R\$ ${_totalRevenue.toStringAsFixed(2)}', Icons.account_balance_wallet, AppColors.neonCyan, 400),
          _statRow('Lucro líquido', 'R\$ ${_netProfit.toStringAsFixed(2)}', Icons.trending_up, AppColors.neonGreen, 500),
          _statRow('Total corridas', '$_totalRides', Icons.directions_car, AppColors.primary, 600),
          _statRow('Km total', '${_totalKm.toStringAsFixed(1)} km', Icons.straighten, AppColors.neonPurple, 700),
          _statRow('Média por km', 'R\$ ${_avgPerKm.toStringAsFixed(2)}/km', Icons.speed, AppColors.neonOrange, 800),
          _statRow('Combustível gasto', 'R\$ ${_fuelCost.toStringAsFixed(2)}', Icons.local_gas_station, AppColors.error, 900),

          const SizedBox(height: 100),
        ]))),
      ),
    );
  }

  Widget _statRow(String label, String value, IconData icon, Color color, int delay) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.05))),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 20)),
      const SizedBox(width: 14),
      Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14))),
      Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700)),
    ]),
  ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.03);
}
