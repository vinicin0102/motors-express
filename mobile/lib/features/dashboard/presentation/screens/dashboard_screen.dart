import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0E21), Color(0xFF141729)]),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 20),

              // Header
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Olá, Motorista 👋', style: Theme.of(context).textTheme.headlineLarge).animate().fadeIn().slideX(begin: -0.1),
                  const SizedBox(height: 4),
                  Text('Seu resumo de hoje', style: Theme.of(context).textTheme.bodyMedium),
                ]),
                GestureDetector(
                  onTap: () => context.go('/subscription'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(gradient: AppColors.proGradient, borderRadius: BorderRadius.circular(20)),
                    child: const Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.workspace_premium, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text('PRO', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
                    ]),
                  ),
                ),
              ]),

              const SizedBox(height: 24),

              // Main Profit Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 30, offset: const Offset(0, 10))],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.trending_up, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    const Text('Lucro hoje', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  ]),
                  const SizedBox(height: 16),
                  const Text('R\$ 187,50', style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.w800, letterSpacing: -2)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                    child: const Text('↑ 23% vs ontem', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ]),
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),

              const SizedBox(height: 20),

              // Stats Grid
              Row(children: [
                Expanded(child: _statCard('🚗', 'Corridas', '12', AppColors.neonCyan, 300)),
                const SizedBox(width: 12),
                Expanded(child: _statCard('📏', 'Km rodados', '48.5', AppColors.neonGreen, 400)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _statCard('⛽', 'Combustível', 'R\$ 32,40', AppColors.neonOrange, 500)),
                const SizedBox(width: 12),
                Expanded(child: _statCard('💰', 'R\$/km', '1,52', AppColors.neonPurple, 600)),
              ]),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _statCard('✅', 'Aceitas', '8', AppColors.success, 700)),
                const SizedBox(width: 12),
                Expanded(child: _statCard('❌', 'Recusadas', '4', AppColors.error, 800)),
              ]),

              const SizedBox(height: 24),

              // Goal Progress
              _goalProgress(context),

              const SizedBox(height: 24),

              // AI Insights
              Text('💡 Insights IA', style: Theme.of(context).textTheme.headlineMedium).animate().fadeIn(delay: 1000.ms),
              const SizedBox(height: 12),
              _insightCard('🕐', 'Entre 18h e 21h sua média aumenta 28%.', AppColors.neonCyan, 1100),
              _insightCard('📍', 'Região Centro-Sul tem corridas mais lucrativas.', AppColors.neonGreen, 1200),
              _insightCard('📊', '85% das corridas analisadas foram boas.', AppColors.neonPurple, 1300),

              const SizedBox(height: 24),

              // Quick Analyze
              SizedBox(width: double.infinity, height: 56, child: Container(
                decoration: BoxDecoration(
                  gradient: AppColors.successGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: AppColors.success.withOpacity(0.3), blurRadius: 20)],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.analytics_outlined),
                  label: const Text('Analisar corrida manualmente', style: TextStyle(fontWeight: FontWeight.w700)),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                ),
              )).animate().fadeIn(delay: 1400.ms),

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _statCard(String emoji, String label, String value, Color color, int delay) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(emoji, style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 8),
        Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppColors.textTertiary, fontSize: 12)),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).scale(begin: const Offset(0.95, 0.95));
  }

  Widget _goalProgress(BuildContext context) {
    const progress = 0.68;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('🎯 Meta diária', style: Theme.of(context).textTheme.titleMedium),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: const Text('68%', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 13)),
          ),
        ]),
        const SizedBox(height: 16),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress, minHeight: 10,
            backgroundColor: Colors.white.withOpacity(0.08),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text('R\$ 187,50 / R\$ 280,00', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          Text('Faltam R\$ 92,50', style: TextStyle(color: AppColors.neonCyan, fontSize: 13, fontWeight: FontWeight.w600)),
        ]),
        const SizedBox(height: 8),
        Text('≈ 6 corridas boas restantes', style: TextStyle(color: AppColors.textTertiary, fontSize: 12)),
      ]),
    ).animate().fadeIn(delay: 900.ms);
  }

  Widget _insightCard(String emoji, String text, Color color, int delay) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(children: [
        Text(emoji, style: const TextStyle(fontSize: 24)),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(color: AppColors.textPrimary, fontSize: 13, fontWeight: FontWeight.w500))),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideX(begin: 0.05);
  }
}
