import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});
  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  bool _yearly = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0E21), Color(0xFF0D1233), Color(0xFF141729)])),
        child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.symmetric(horizontal: 20), child: Column(children: [
          const SizedBox(height: 12),
          Align(alignment: Alignment.centerLeft, child: IconButton(icon: const Icon(Icons.close, color: AppColors.textPrimary), onPressed: () => context.pop())),
          const SizedBox(height: 8),

          // Header
          const Text('🚀', style: TextStyle(fontSize: 48)).animate().fadeIn().scale(begin: const Offset(0.5, 0.5), curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text('Desbloqueie todo o potencial', style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800), textAlign: TextAlign.center).animate().fadeIn(delay: 200.ms),
          const SizedBox(height: 8),
          Text('Pare de aceitar corridas ruins.\nAumente seu lucro diário com IA.', style: Theme.of(context).textTheme.bodyLarge, textAlign: TextAlign.center).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 24),

          // Billing toggle
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(14)),
            child: Row(children: [
              Expanded(child: GestureDetector(
                onTap: () => setState(() => _yearly = false),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: !_yearly ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Text('Mensal', style: TextStyle(fontWeight: FontWeight.w600, color: !_yearly ? Colors.white : AppColors.textTertiary))),
                ),
              )),
              Expanded(child: GestureDetector(
                onTap: () => setState(() => _yearly = true),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(color: _yearly ? AppColors.primary : Colors.transparent, borderRadius: BorderRadius.circular(10)),
                  child: Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('Anual', style: TextStyle(fontWeight: FontWeight.w600, color: _yearly ? Colors.white : AppColors.textTertiary)),
                    if (_yearly) ...[const SizedBox(width: 6), Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: AppColors.neonGreen, borderRadius: BorderRadius.circular(4)), child: const Text('-17%', style: TextStyle(color: Colors.black, fontSize: 10, fontWeight: FontWeight.w800)))],
                  ])),
                ),
              )),
            ]),
          ).animate().fadeIn(delay: 400.ms),

          const SizedBox(height: 24),

          // FREE Plan
          _planCard(
            name: 'FREE', price: 'Grátis', period: '', badge: null,
            features: ['Dashboard básico', 'Meta diária simples', 'Cálculo manual', 'Máx 20 análises/dia'],
            gradient: null, borderColor: Colors.white.withOpacity(0.1), selected: false, delay: 500,
          ),

          // PRO Plan
          _planCard(
            name: 'PRO', price: _yearly ? 'R\$ 16,42' : 'R\$ 19,90', period: '/mês', badge: '⭐ Mais popular',
            features: ['Overlay em tempo real', 'Leitura automática', 'IA de metas', 'Dashboard premium', 'Estatísticas completas', 'Insights inteligentes', 'Notificações inteligentes'],
            gradient: AppColors.proGradient, borderColor: AppColors.primary, selected: true, delay: 600,
            totalYearly: _yearly ? 'R\$ 197,00/ano' : null,
          ),

          // PREMIUM Plan
          _planCard(
            name: 'PREMIUM', price: _yearly ? 'R\$ 41,42' : 'R\$ 49,90', period: '/mês', badge: '👑 Máximo desempenho',
            features: ['Tudo do PRO', 'IA preditiva avançada', 'Heatmap em tempo real', 'Relatórios avançados', 'Multi veículos', 'Suporte prioritário', 'Recursos beta'],
            gradient: AppColors.premiumGradient, borderColor: AppColors.neonOrange, selected: false, delay: 700,
            totalYearly: _yearly ? 'R\$ 497,00/ano' : null,
          ),

          const SizedBox(height: 16),

          // CTA
          Text('Descubra instantaneamente se a corrida vale a pena.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13), textAlign: TextAlign.center).animate().fadeIn(delay: 800.ms),
          const SizedBox(height: 8),
          Text('Motoristas estão lucrando mais usando Driver AI.', style: TextStyle(color: AppColors.neonCyan, fontSize: 13, fontWeight: FontWeight.w600), textAlign: TextAlign.center).animate().fadeIn(delay: 900.ms),

          const SizedBox(height: 16),

          // Trial button
          SizedBox(width: double.infinity, height: 56, child: Container(
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8))]),
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
              child: const Text('Começar teste grátis de 7 dias', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          )).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.1),

          const SizedBox(height: 12),
          Text('Sem cobrança imediata. Cancele a qualquer momento.', style: TextStyle(color: AppColors.textTertiary, fontSize: 12), textAlign: TextAlign.center).animate().fadeIn(delay: 1100.ms),

          // Coupon
          const SizedBox(height: 20),
          TextButton(onPressed: () {}, child: const Text('Tem um cupom? Usar aqui', style: TextStyle(color: AppColors.primary))).animate().fadeIn(delay: 1200.ms),

          const SizedBox(height: 40),
        ]))),
      ),
    );
  }

  Widget _planCard({required String name, required String price, required String period, String? badge, required List<String> features, LinearGradient? gradient, required Color borderColor, required bool selected, required int delay, String? totalYearly}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: selected ? 2 : 1),
        boxShadow: selected ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 20)] : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(name, style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w800)),
          if (badge != null) ...[const Spacer(), Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(gradient: gradient, borderRadius: BorderRadius.circular(8)), child: Text(badge, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)))],
        ]),
        const SizedBox(height: 12),
        Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(price, style: TextStyle(color: AppColors.textPrimary, fontSize: 32, fontWeight: FontWeight.w800)),
          if (period.isNotEmpty) Padding(padding: const EdgeInsets.only(bottom: 4, left: 2), child: Text(period, style: TextStyle(color: AppColors.textTertiary, fontSize: 14))),
        ]),
        if (totalYearly != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(totalYearly, style: TextStyle(color: AppColors.textTertiary, fontSize: 12))),
        const SizedBox(height: 16),
        ...features.map((f) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Row(children: [
          Icon(Icons.check_circle, color: selected ? AppColors.neonCyan : AppColors.textTertiary, size: 18),
          const SizedBox(width: 10),
          Text(f, style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ]))),
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.03);
  }
}
