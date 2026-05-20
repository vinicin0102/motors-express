import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_theme.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0E21), Color(0xFF141729)])),
        child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('🎯 Metas', style: Theme.of(context).textTheme.displayMedium).animate().fadeIn(),
          const SizedBox(height: 8),
          Text('Acompanhe seu progresso', style: Theme.of(context).textTheme.bodyLarge).animate().fadeIn(delay: 100.ms),
          const SizedBox(height: 24),

          _goalCard('Meta diária', 187.50, 280.00, AppColors.primary, '5 corridas boas restantes', 200),
          _goalCard('Meta semanal', 842.30, 1400.00, AppColors.neonCyan, '≈ 3 dias de trabalho', 400),
          _goalCard('Meta mensal', 3250.00, 5600.00, AppColors.neonGreen, 'Você está no caminho certo!', 600),

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
              const Text('Faltam R\$ 92,50 para sua meta!', style: TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Estimativa: 5 corridas boas restantes.', style: TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.3), borderRadius: BorderRadius.circular(10)),
                child: const Text('Você consegue! 🚀', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.w600)),
              ),
            ]),
          ).animate().fadeIn(delay: 800.ms).scale(begin: const Offset(0.95, 0.95)),

          const SizedBox(height: 24),

          // Edit goals button
          SizedBox(width: double.infinity, height: 56, child: OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.edit),
            label: const Text('Editar metas'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
          )).animate().fadeIn(delay: 1000.ms),

          const SizedBox(height: 100),
        ]))),
      ),
    );
  }

  Widget _goalCard(String title, double current, double target, Color color, String estimate, int delay) {
    final progress = current / target;
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
          Text('Faltam R\$ ${(target - current).toStringAsFixed(2)}', style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 6),
        Text(estimate, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.05);
  }
}
