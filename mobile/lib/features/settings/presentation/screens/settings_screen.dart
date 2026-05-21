import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> with WidgetsBindingObserver {
  bool _overlayActive = false;
  bool _accessibilityActive = false;
  String _userName = 'Motorista';
  String _userInitials = 'M';

  static const _channel = MethodChannel('com.driverai.app/permissions');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkStatus();
    _loadProfile();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _checkStatus();
  }

  Future<void> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final name = prefs.getString('user_name');
      if (name != null && name.isNotEmpty) {
        if (mounted) {
          setState(() {
            _userName = name;
            _userInitials = name.substring(0, 1).toUpperCase();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading profile: $e');
    }
  }

  Future<void> _checkStatus() async {
    try {
      final overlay = await _channel.invokeMethod<bool>('checkOverlayPermission') ?? false;
      final accessibility = await _channel.invokeMethod<bool>('checkAccessibilityPermission') ?? false;
      if (mounted) setState(() { _overlayActive = overlay; _accessibilityActive = accessibility; });
    } catch (e) { /* channel not available */ }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0E21), Color(0xFF141729)])),
        child: SafeArea(child: SingleChildScrollView(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('⚙️ Configurações', style: Theme.of(context).textTheme.displayMedium).animate().fadeIn(),
          const SizedBox(height: 24),

          // Profile card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(color: AppColors.bgCard, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.05))),
            child: Row(children: [
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16)),
                child: Center(child: Text(_userInitials, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700))),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_userName, style: const TextStyle(color: AppColors.textPrimary, fontSize: 18, fontWeight: FontWeight.w700)),
                const Text('motorista@email.com', style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
              ])),
              const Icon(Icons.chevron_right, color: AppColors.textTertiary),
            ]),
          ).animate().fadeIn(delay: 200.ms),

          const SizedBox(height: 16),

          // Subscription
          GestureDetector(
            onTap: () => context.go('/subscription'),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.15), AppColors.neonCyan.withOpacity(0.08)]),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.workspace_premium, color: AppColors.neonCyan, size: 28),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Plano PRO', style: TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                  const Text('Renova em 15 dias', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(8)),
                  child: const Text('Ativo', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 12)),
                ),
              ]),
            ),
          ).animate().fadeIn(delay: 300.ms),

          const SizedBox(height: 24),

          _section('Conta'),
          _item(Icons.person_outline, 'Editar perfil', 400),
          _item(Icons.directions_car, 'Meus veículos', 500),
          _item(Icons.notifications_outlined, 'Notificações', 600),
          _item(Icons.lock_outline, 'Segurança', 700),

          const SizedBox(height: 16),
          _section('Copiloto IA'),

          // Accessibility Service - with status
          _permissionItem(
            icon: Icons.accessibility_new,
            label: 'Serviço de Acessibilidade',
            active: _accessibilityActive,
            onTap: () async {
              try { await _channel.invokeMethod('requestAccessibilityPermission'); } catch (e) {}
            },
            delay: 800,
          ),

          // Overlay - with status
          _permissionItem(
            icon: Icons.layers_outlined,
            label: 'Overlay flutuante',
            active: _overlayActive,
            onTap: () async {
              try { await _channel.invokeMethod('requestOverlayPermission'); } catch (e) {}
            },
            delay: 900,
          ),

          const SizedBox(height: 16),
          _section('Social'),
          _item(Icons.share_outlined, 'Indicar amigos', 1000),
          _item(Icons.card_giftcard, 'Cupom de desconto', 1100),

          const SizedBox(height: 16),
          _section('Sobre'),
          _item(Icons.help_outline, 'Ajuda', 1200),
          _item(Icons.privacy_tip_outlined, 'Política de privacidade', 1300),
          _item(Icons.description_outlined, 'Termos de uso', 1400),
          _item(Icons.info_outline, 'Versão 1.2.0', 1500),

          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 52, child: OutlinedButton.icon(
            onPressed: () => context.go('/login'),
            icon: const Icon(Icons.logout, color: AppColors.error),
            label: const Text('Sair da conta', style: TextStyle(color: AppColors.error)),
            style: OutlinedButton.styleFrom(side: const BorderSide(color: AppColors.error), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          )).animate().fadeIn(delay: 1600.ms),

          const SizedBox(height: 100),
        ]))),
      ),
    );
  }

  Widget _section(String title) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(title, style: const TextStyle(color: AppColors.textTertiary, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 1)),
  );

  Widget _item(IconData icon, String label, int delay) => Container(
    margin: const EdgeInsets.only(bottom: 4),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      leading: Icon(icon, color: AppColors.textSecondary, size: 22),
      title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.textTertiary, size: 20),
      onTap: () {},
    ),
  ).animate().fadeIn(delay: Duration(milliseconds: delay));

  Widget _permissionItem({required IconData icon, required String label, required bool active, required VoidCallback onTap, required int delay}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 4),
        leading: Icon(icon, color: active ? AppColors.success : AppColors.textSecondary, size: 22),
        title: Text(label, style: const TextStyle(color: AppColors.textPrimary, fontSize: 15)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.success.withOpacity(0.15) : AppColors.error.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            active ? 'Ativo' : 'Inativo',
            style: TextStyle(color: active ? AppColors.success : AppColors.error, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ),
        onTap: onTap,
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay));
  }
}
