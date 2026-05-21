import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Map<String, dynamic>> _rides = [];
  double _costPerKm = 0.49;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final costStr = prefs.getString('cost_per_km') ?? '0.49';
      _costPerKm = double.tryParse(costStr) ?? 0.49;

      final historyStr = prefs.getString('ride_history');
      if (historyStr != null) {
        final List<dynamic> jsonList = jsonDecode(historyStr);
        _rides = jsonList.map((e) => e as Map<String, dynamic>).toList();
        // Sort by timestamp descending
        _rides.sort((a, b) => (b['timestamp'] as int).compareTo(a['timestamp'] as int));
      }
    } catch (e) {
      debugPrint('Error loading history: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0E21), Color(0xFF141729)])),
        child: SafeArea(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('📋 Histórico', style: Theme.of(context).textTheme.displayMedium).animate().fadeIn(),
            const SizedBox(height: 8),
            Text('Todas as corridas analisadas', style: Theme.of(context).textTheme.bodyLarge).animate().fadeIn(delay: 100.ms),
          ])),
          
          Expanded(child: _loading 
            ? const Center(child: CircularProgressIndicator())
            : _rides.isEmpty 
              ? Center(child: Text('Nenhuma corrida detectada hoje', style: TextStyle(color: AppColors.textTertiary, fontSize: 16)))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _rides.length,
            itemBuilder: (ctx, i) {
              final r = _rides[i];
              
              final value = (r['value'] as num).toDouble();
              final dist = (r['distance'] as num).toDouble();
              final vpk = dist > 0 ? value / dist : 0.0;
              final ratio = _costPerKm > 0 ? vpk / _costPerKm : 0.0;
              
              String rating;
              if (ratio >= 3.0) rating = 'EXCELLENT';
              else if (ratio >= 2.0) rating = 'GOOD';
              else if (ratio >= 1.2) rating = 'AVERAGE';
              else rating = 'BAD';

              final color = _ratingColor(rating);
              final emoji = _ratingEmoji(rating);
              
              final dt = DateTime.fromMillisecondsSinceEpoch(r['timestamp'] as int);
              final timeStr = DateFormat('HH:mm').format(dt);

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
                        Text('R\$ ${value.toStringAsFixed(2)}', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                        const SizedBox(width: 8),
                        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(6)),
                          child: Text('R\$ ${vpk.toStringAsFixed(2)}/km', style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700))),
                      ]),
                      const SizedBox(height: 4),
                      Text('${r['platform']} • ${(r['duration'] as num?) ?? 0} min', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text(timeStr, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
                    ]),
                  ]),
                  const SizedBox(height: 10),
                  Row(children: [
                    _tag('📏 ${dist.toStringAsFixed(1)} km'),
                  ]),
                ]),
              ).animate().fadeIn(delay: Duration(milliseconds: 50 + (i < 5 ? i * 50 : 0))).slideX(begin: 0.03);
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
