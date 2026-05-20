import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  String _platform = 'UBER';
  bool _obscure = true;
  bool _loading = false;

  final _platforms = [
    {'value': 'UBER', 'label': 'Uber', 'icon': Icons.local_taxi},
    {'value': 'NINETY_NINE', 'label': '99', 'icon': Icons.directions_car},
    {'value': 'INDRIVE', 'label': 'InDrive', 'icon': Icons.car_rental},
    {'value': 'OTHER', 'label': 'Outros', 'icon': Icons.more_horiz},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0A0E21), Color(0xFF141729)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(height: 20),
                IconButton(
                  onPressed: () => context.go('/login'),
                  icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),
                Text('Criar conta', style: Theme.of(context).textTheme.displayMedium).animate().fadeIn().slideX(begin: -0.1),
                const SizedBox(height: 8),
                Text('Preencha seus dados para começar', style: Theme.of(context).textTheme.bodyLarge).animate().fadeIn(delay: 100.ms),
                const SizedBox(height: 32),

                _buildField('Nome completo', _nameCtrl, Icons.person_outline, 'Seu nome', delay: 200),
                _buildField('Telefone', _phoneCtrl, Icons.phone_outlined, '(11) 99999-9999', delay: 300, type: TextInputType.phone),
                _buildField('Email', _emailCtrl, Icons.email_outlined, 'seu@email.com', delay: 400, type: TextInputType.emailAddress),
                
                _buildLabel('Senha', 500),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _passwordCtrl, obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    prefixIcon: const Icon(Icons.lock_outline, color: AppColors.textTertiary),
                    suffixIcon: IconButton(
                      icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppColors.textTertiary),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) => (v?.length ?? 0) < 6 ? 'Mínimo 6 caracteres' : null,
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 20),

                _buildField('Cidade', _cityCtrl, Icons.location_city_outlined, 'São Paulo', delay: 600),

                // Platform selector
                _buildLabel('Plataforma principal', 700),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 10, runSpacing: 10,
                  children: _platforms.map((p) {
                    final selected = _platform == p['value'];
                    return GestureDetector(
                      onTap: () => setState(() => _platform = p['value'] as String),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary.withOpacity(0.2) : AppColors.bgCardLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: selected ? AppColors.primary : Colors.white.withOpacity(0.08), width: selected ? 2 : 1),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Icon(p['icon'] as IconData, size: 20, color: selected ? AppColors.neonCyan : AppColors.textTertiary),
                          const SizedBox(width: 8),
                          Text(p['label'] as String, style: TextStyle(color: selected ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
                        ]),
                      ),
                    );
                  }).toList(),
                ).animate().fadeIn(delay: 700.ms),

                const SizedBox(height: 32),

                // Register button
                SizedBox(
                  width: double.infinity, height: 56,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))],
                    ),
                    child: ElevatedButton(
                      onPressed: _loading ? null : _handleRegister,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                      child: _loading
                        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('Criar conta', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),

                const SizedBox(height: 24),
                Center(child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text('Já tem uma conta? ', style: TextStyle(color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: const Text('Entre aqui', style: TextStyle(color: AppColors.neonCyan, fontWeight: FontWeight.w600)),
                  ),
                ])),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, int delay) => Text(text, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14, fontWeight: FontWeight.w500)).animate().fadeIn(delay: Duration(milliseconds: delay));

  Widget _buildField(String label, TextEditingController ctrl, IconData icon, String hint, {required int delay, TextInputType type = TextInputType.text}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildLabel(label, delay),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl, keyboardType: type,
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: AppColors.textTertiary)),
        validator: (v) => (v?.isEmpty ?? true) ? 'Campo obrigatório' : null,
      ).animate().fadeIn(delay: Duration(milliseconds: delay)),
      const SizedBox(height: 20),
    ]);
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) { setState(() => _loading = false); context.go('/vehicle-setup'); }
  }
}
