import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class PermissionsSetupScreen extends StatefulWidget {
  const PermissionsSetupScreen({super.key});
  @override
  State<PermissionsSetupScreen> createState() => _PermissionsSetupScreenState();
}

class _PermissionsSetupScreenState extends State<PermissionsSetupScreen> with WidgetsBindingObserver {
  bool _overlayGranted = false;
  bool _accessibilityGranted = false;

  static const _channel = MethodChannel('com.driverai.app/permissions');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermissions();
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final overlay = await _channel.invokeMethod<bool>('checkOverlayPermission') ?? false;
      final accessibility = await _channel.invokeMethod<bool>('checkAccessibilityPermission') ?? false;
      if (mounted) {
        setState(() {
          _overlayGranted = overlay;
          _accessibilityGranted = accessibility;
        });
      }
    } catch (e) {
      // Platform channel not available, skip
    }
  }

  Future<void> _requestOverlay() async {
    try {
      await _channel.invokeMethod('requestOverlayPermission');
    } catch (e) {
      // Fallback: show manual instructions
    }
  }

  Future<void> _requestAccessibility() async {
    try {
      await _channel.invokeMethod('requestAccessibilityPermission');
    } catch (e) {
      // Fallback: show manual instructions
    }
  }

  @override
  Widget build(BuildContext context) {
    final allGranted = _overlayGranted && _accessibilityGranted;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0E21), Color(0xFF141729)]),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 20),
              // Progress bar
              Row(children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 4),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 4),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
              ]).animate().fadeIn(),
              const SizedBox(height: 32),

              Text('Ativar o Copiloto', style: Theme.of(context).textTheme.displayMedium).animate().fadeIn().slideX(begin: -0.1),
              const SizedBox(height: 8),
              Text('Para analisar corridas automaticamente, precisamos de 2 permissões especiais:', style: Theme.of(context).textTheme.bodyLarge).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 32),

              // Step 1: Overlay
              _permissionCard(
                step: 1,
                title: 'Desenhar sobre outros apps',
                description: 'Permite que a bolha do Driver AI apareça por cima do Uber, 99, etc. quando uma corrida apitar.',
                icon: Icons.layers,
                granted: _overlayGranted,
                onTap: _requestOverlay,
                delay: 200,
              ),

              const SizedBox(height: 16),

              // Step 2: Accessibility
              _permissionCard(
                step: 2,
                title: 'Serviço de Acessibilidade',
                description: 'Permite que o Driver AI leia as informações da corrida (valor, distância) na tela do app de corrida.',
                icon: Icons.accessibility_new,
                granted: _accessibilityGranted,
                onTap: _requestAccessibility,
                delay: 400,
                extraInstructions: 'Encontre "Driver AI" na lista e ative a chavinha.',
              ),

              const SizedBox(height: 32),

              // Info box (Configuração Restrita)
              if (!_accessibilityGranted) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.neonOrange.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.neonOrange.withOpacity(0.3)),
                  ),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.neonOrange, size: 24),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Acessibilidade Bloqueada?', style: TextStyle(color: AppColors.neonOrange, fontSize: 14, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(
                        'Se aparecer "Configuração Restrita", vá nas Configurações do Celular > Aplicativos > Driver AI > clique nos 3 pontinhos no canto superior direito > "Permitir configurações restritas".',
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                      ),
                    ])),
                  ]),
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 16),
              ],

              // Info box (Privacidade)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.neonCyan.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.neonCyan.withOpacity(0.2)),
                ),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Icon(Icons.shield_outlined, color: AppColors.neonCyan, size: 24),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('Sua privacidade é prioridade', style: TextStyle(color: AppColors.neonCyan, fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 4),
                    Text(
                      'O Driver AI só lê informações dos apps de corrida (Uber, 99, InDrive). Nenhum dado pessoal, senha ou mensagem é acessada.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.4),
                    ),
                  ])),
                ]),
              ).animate().fadeIn(delay: 600.ms),

              const SizedBox(height: 32),

              // Continue button
              SizedBox(width: double.infinity, height: 56, child: Container(
                decoration: BoxDecoration(
                  gradient: allGranted ? AppColors.successGradient : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: (allGranted ? AppColors.success : AppColors.primary).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                ),
                child: ElevatedButton(
                  onPressed: () => context.go('/dashboard'),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: Text(
                    allGranted ? '✅ Tudo pronto! Vamos começar' : 'Pular por agora →',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              )).animate().fadeIn(delay: 700.ms),

              if (!allGranted) ...[
                const SizedBox(height: 12),
                Center(child: Text(
                  'Você pode ativar depois em Configurações',
                  style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                )).animate().fadeIn(delay: 800.ms),
              ],

              const SizedBox(height: 32),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _permissionCard({
    required int step,
    required String title,
    required String description,
    required IconData icon,
    required bool granted,
    required VoidCallback onTap,
    required int delay,
    String? extraInstructions,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: granted ? AppColors.success.withOpacity(0.08) : AppColors.bgCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: granted ? AppColors.success.withOpacity(0.4) : Colors.white.withOpacity(0.08),
          width: granted ? 2 : 1,
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // Step number / check
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: granted ? AppColors.success : AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(child: granted
              ? const Icon(Icons.check, color: Colors.white, size: 20)
              : Text('$step', style: const TextStyle(color: AppColors.neonCyan, fontSize: 18, fontWeight: FontWeight.w800)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
            if (granted)
              const Text('✅ Ativado', style: TextStyle(color: AppColors.success, fontSize: 13, fontWeight: FontWeight.w600)),
          ])),
          Icon(icon, color: granted ? AppColors.success : AppColors.textTertiary, size: 28),
        ]),
        const SizedBox(height: 12),
        Text(description, style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),

        if (extraInstructions != null && !granted) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.neonOrange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(children: [
              const Icon(Icons.info_outline, color: AppColors.neonOrange, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(extraInstructions, style: const TextStyle(color: AppColors.neonOrange, fontSize: 12, fontWeight: FontWeight.w500))),
            ]),
          ),
        ],

        if (!granted) ...[
          const SizedBox(height: 16),
          SizedBox(width: double.infinity, height: 48, child: ElevatedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.settings, size: 20),
            label: const Text('Abrir configurações', style: TextStyle(fontWeight: FontWeight.w700)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary.withOpacity(0.2),
              foregroundColor: AppColors.neonCyan,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              side: BorderSide(color: AppColors.primary.withOpacity(0.5)),
            ),
          )),
        ],
      ]),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).slideY(begin: 0.05);
  }
}
