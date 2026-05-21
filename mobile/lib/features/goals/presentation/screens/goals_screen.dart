import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  double _dailyGoal = 200.0;
  double _weeklyGoal = 1000.0;
  double _monthlyGoal = 4000.0;
  
  double _currentRevenue = 0.0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  Future<void> _loadGoals() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _dailyGoal = double.tryParse(prefs.getString('daily_goal') ?? '200') ?? 200.0;
      _weeklyGoal = double.tryParse(prefs.getString('weekly_goal') ?? '1000') ?? 1000.0;
      _monthlyGoal = double.tryParse(prefs.getString('monthly_goal') ?? '4000') ?? 4000.0;

      final historyStr = prefs.getString('ride_history');
      if (historyStr != null) {
        final List<dynamic> jsonList = jsonDecode(historyStr);
        for (var e in jsonList) {
          final r = e as Map<String, dynamic>;
          // For simplicity, we assume all history is "today" right now
          _currentRevenue += (r['value'] as num).toDouble();
        }
      }
    } catch (e) {
      debugPrint('Error loading goals: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = _dailyGoal - _currentRevenue;
    final remainingText = remaining > 0 ? 'Faltam R\$ ${remaining.toStringAsFixed(2)} para sua meta diária!' : 'Meta diária batida! Parabéns! 🎉';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0E21), Color(0xFF141729)])),
        child: SafeArea(child: _loading ? const Center(child: CircularProgressIndicator()) : SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('🎯 Metas', style: Theme.of(context).textTheme.displayMedium).animate().fadeIn(),
          const SizedBox(height: 8),
          Text('Acompanhe seu progresso', style: Theme.of(context).textTheme.bodyLarge).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 24),

          _goalCard('Meta diária', _currentRevenue, _dailyGoal, AppColors.primary, remaining > 0 ? 'Foco!' : 'Concluído!', 200),
          _goalCard('Meta semanal', _currentRevenue, _weeklyGoal, AppColors.neonCyan, 'Progresso da semana', 400),
          _goalCard('Meta mensal', _currentRevenue, _monthlyGoal, AppColors.neonGreen, 'Progresso do mês', 600),

          const SizedBox(height: 24),

          // Motivational card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.15), AppColors.neonCyan.withOpacity(0.08)]),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('💪', style: TextStyle(fontSize: 32)),
              const SizedBox(height: 12),
              Text(remainingText, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 16),
              if (remaining > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                  child: const Text('Você consegue! 🚀', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.w600)),
                ),
            ]),
          ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 100),
        ]))),
      ),
    );
  }

  Widget _goalCard(String title, double current, double target, Color color, String estimate, int delay) {
    double progress = target > 0 ? current / target : 0;
    if (progress > 1.0) progress = 1.0;
    
    final rem = target - current;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: color.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: Text('${(progress * 100).toStringAsFixed(0)}%', style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ]),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: Colors.white.withOpacity(0.08), valueColor: AlwaysStoppedAnimation(color)),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('R\$ ${current.toStringAsFixed(2)} / R\$ ${target.toStringAsFixed(2)}', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          if (rem > 0)
            Text('Faltam R\$ ${rem.toStringAsFixed(2)}', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600))
          else
            Text('Atingida!', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6),
        Text(estimate, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.05);
  }
}
