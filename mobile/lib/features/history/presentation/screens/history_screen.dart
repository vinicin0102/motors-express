import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rides = [
      {'value': 'R\$ 22,50', 'km': '8.2 km', 'perKm': '2.74', 'rating': 'EXCELLENT', 'time': '19:42', 'from': 'Centro', 'to': 'Zona Sul', 'accepted': true},
      {'value': 'R\$ 15,00', 'km': '12.5 km', 'perKm': '1.20', 'rating': 'AVERAGE', 'time': '18:15', 'from': 'Barra', 'to': 'Centro', 'accepted': true},
      {'value': 'R\$ 8,50', 'km': '11.0 km', 'perKm': '0.77', 'rating': 'BAD', 'time': '17:30', 'from': 'Norte', 'to': 'Leste', 'accepted': false},
      {'value': 'R\$ 18,00', 'km': '9.0 km', 'perKm': '2.00', 'rating': 'GOOD', 'time': '16:05', 'from': 'Sul', 'to': 'Centro', 'accepted': true},
      {'value': 'R\$ 35,00', 'km': '15.3 km', 'perKm': '2.29', 'rating': 'EXCELLENT', 'time': '14:20', 'from': 'Aeroporto', 'to': 'Hotel', 'accepted': true},
      {'value': 'R\$ 12,00', 'km': '14.0 km', 'perKm': '0.86', 'rating': 'BAD', 'time': '12:40', 'from': 'Leste', 'to': 'Norte', 'accepted': false},
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0E21), Color(0xFF141729)])),
        child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('📋 Histórico', style: Theme.of(context).textTheme.displayMedium).animate().fadeIn(),
            const SizedBox(height: 8),
            Text('Todas as corridas analisadas', style: Theme.of(context).textTheme.bodyLarge).animate().fadeIn(delay: 100.ms),
          ])),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: rides.length,
            itemBuilder: (ctx, i) {
              final r = rides[i];
              final color = _ratingColor(r['rating'] as String);
              final emoji = _ratingEmoji(r['rating'] as String);
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                  boxShadow: [BoxShadow(color: color.withOpacity(0.05), blurRadius: 10)],
                ),
                child: Column(children: [
                  Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 20))),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [
                        Text(r['value'] as String, style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                          child: Text('R\$ ${r['perKm']}/km', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700))),
                      ]),
                      const SizedBox(height: 4),
                      Text('${r['from']} → ${r['to']}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(r['time'] as String, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                      const SizedBox(height: 4),
                      Icon(r['accepted'] == true ? Icons.check_circle : Icons.cancel, size: 18, color: r['accepted'] == true ? AppColors.success : AppColors.error),
                    ]),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    _tag('📏 ${r['km']}'),
                    const SizedBox(width: 8),
                    _tag(r['accepted'] == true ? '✅ Aceita' : '❌ Recusada'),
                  ]),
                ]),
              ).animate().fadeIn(delay: Duration(milliseconds: 200 + i * 100)).slideX(begin: 0.03);
            },
          )),
        ])),
      ),
    );
  }

  Widget _tag(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
    child: Text(text, style: const TextStyle(color: AppColors.textTertiary, fontSize: 11)),
  );

  Color _ratingColor(String r) => switch (r) { 'EXCELLENT' => AppColors.neonGreen, 'GOOD' => AppColors.neonCyan, 'AVERAGE' => AppColors.warning, _ => AppColors.error };
  String _ratingEmoji(String r) => switch (r) { 'EXCELLENT' => '🟢', 'GOOD' => '🟢', 'AVERAGE' => '🟡', _ => '🔴' };
}
