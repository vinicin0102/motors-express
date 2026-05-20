import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0E21), Color(0xFF141729)])),
        child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('📊 Estatísticas', style: Theme.of(context).textTheme.displayMedium).animate().fadeIn(),
          const SizedBox(height: 8),
          Text('Seus números em detalhes', style: Theme.of(context).textTheme.bodyLarge).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 24),

          // Period selector
          Row(children: ['Hoje', 'Semana', 'Mês', 'Ano'].asMap().entries.map((e) => Expanded(child: GestureDetector(
            child: Container(
              margin: EdgeInsets.only(right: e.key < 3 ? 8 : 0),
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: e.key == 1 ? AppColors.primary : AppColors.bgCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: e.key == 1 ? AppColors.primary : Colors.white.withOpacity(0.05)),
              ),
              child: Center(child: Text(e.value, style: TextStyle(fontWeight: e.key == 1 ? FontWeight.w700 : FontWeight.w400, fontSize: 13, color: e.key == 1 ? Colors.white : AppColors.textSecondary))),
            ),
          ))).toList()).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 24),

          // Chart placeholder
          Container(
            height: 200,
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Ganhos da semana', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 8),
              const Text('R\$ 1.247,80', style: TextStyle(color: AppColors.textPrimary, fontSize: 28, fontWeight: FontWeight.w800)),
              const SizedBox(height: 20),
              Expanded(child: Row(crossAxisAlignment: CrossAxisAlignment.end, mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _bar('Seg', 0.6, AppColors.primary),
                _bar('Ter', 0.8, AppColors.primary),
                _bar('Qua', 0.45, AppColors.primary),
                _bar('Qui', 0.9, AppColors.neonCyan),
                _bar('Sex', 1.0, AppColors.neonCyan),
                _bar('Sáb', 0.7, AppColors.primary),
                _bar('Dom', 0.3, AppColors.textTertiary),
              ])),
            ]),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 20),

          // Stats grid
          _statRow('Receita total', 'R\$ 1.247,80', Icons.account_balance_wallet, AppColors.neonCyan, 400),
          _statRow('Lucro líquido', 'R\$ 982,40', Icons.trending_up, AppColors.neonGreen, 500),
          _statRow('Total corridas', '67', Icons.directions_car, AppColors.primary, 600),
          _statRow('Km total', '312,5 km', Icons.straighten, AppColors.neonPurple, 700),
          _statRow('Média por km', 'R\$ 1,48/km', Icons.speed, AppColors.neonOrange, 800),
          _statRow('Combustível gasto', 'R\$ 265,40', Icons.local_gas_station, AppColors.error, 900),
          _statRow('Tempo online', '42h 30min', Icons.timer, AppColors.info, 1000),
          _statRow('Taxa aceitação', '76%', Icons.check_circle, AppColors.success, 1100),

          const SizedBox(height: 24),

          // Best times
          Text('🕐 Melhores horários', style: Theme.of(context).textTheme.headlineMedium).animate().fadeIn(delay: 1200.ms),
          const SizedBox(height: 12),
          _timeCard('18:00 - 21:00', 'R\$ 2.10/km', '🔥 Pico', AppColors.neonOrange, 1300),
          _timeCard('07:00 - 09:00', 'R\$ 1.85/km', '⚡ Alto', AppColors.neonCyan, 1400),
          _timeCard('12:00 - 14:00', 'R\$ 1.42/km', '📊 Médio', AppColors.primary, 1500),

          const SizedBox(height: 100),
        ]))),
      ),
    );
  }

  Widget _bar(String label, double h, Color color) => Column(mainAxisAlignment: MainAxisAlignment.end, children: [
    Container(width: 28, height: 80 * h, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(6))),
    const SizedBox(height: 6),
    Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 10)),
  ]);

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

  Widget _timeCard(String time, String value, String badge, Color color, int delay) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.2))),
    child: Row(children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(time, style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
        Text(value, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
      ]),
      const Spacer(),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)), child: Text(badge, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600))),
    ]),
  ).animate().fadeIn(delay: Duration(milliseconds: delay));
}
