import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_theme.dart';

class VehicleSetupScreen extends StatefulWidget {
  const VehicleSetupScreen({super.key});
  @override
  State<VehicleSetupScreen> createState() => _VehicleSetupScreenState();
}

class _VehicleSetupScreenState extends State<VehicleSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandCtrl = TextEditingController();
  final _modelCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _consumptionCtrl = TextEditingController();
  final _fuelPriceCtrl = TextEditingController();
  final _dailyGoalCtrl = TextEditingController();
  final _weeklyGoalCtrl = TextEditingController();
  final _monthlyGoalCtrl = TextEditingController();
  String _fuelType = 'GASOLINE';
  String _vehicleType = 'CAR'; // CAR or MOTO
  bool _loading = false;

  final _fuels = [
    {'value': 'GASOLINE', 'label': 'Gasolina', 'icon': Icons.local_gas_station},
    {'value': 'ETHANOL', 'label': 'Etanol', 'icon': Icons.eco},
    {'value': 'CNG', 'label': 'GNV', 'icon': Icons.air},
    {'value': 'DIESEL', 'label': 'Diesel', 'icon': Icons.oil_barrel},
    {'value': 'ELECTRIC', 'label': 'Elétrico', 'icon': Icons.bolt},
  ];

  @override
  Widget build(BuildContext context) {
    final isMoto = _vehicleType == 'MOTO';
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF0A0E21), Color(0xFF141729)]),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 20),
              // Progress
              Row(children: [
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 4),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(2))),
                const SizedBox(width: 4),
                Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(2))),
              ]).animate().fadeIn(),
              const SizedBox(height: 32),

              Text('Configure seu veículo', style: Theme.of(context).textTheme.displayMedium).animate().fadeIn().slideX(begin: -0.1),
              const SizedBox(height: 8),
              Text('Precisamos dessas informações para calcular seus custos', style: Theme.of(context).textTheme.bodyLarge).animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 32),

              // Vehicle Type Selector
              _sectionTitle('🚘 Tipo de Veículo', 150),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: _vehicleTypeCard('CAR', '🚗', 'Carro', 200)),
                const SizedBox(width: 12),
                Expanded(child: _vehicleTypeCard('MOTO', '🏍️', 'Moto', 300)),
              ]),
              const SizedBox(height: 24),

              // Vehicle section
              _sectionTitle(isMoto ? '🏍️ Moto' : '🚗 Veículo', 400),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _input('Marca', _brandCtrl, isMoto ? Icons.two_wheeler : Icons.directions_car, isMoto ? 'Honda' : 'Toyota', 500)),
                const SizedBox(width: 12),
                Expanded(child: _input('Modelo', _modelCtrl, Icons.car_repair, isMoto ? 'CG 160' : 'Corolla', 600)),
              ]),
              _input('Ano', _yearCtrl, Icons.calendar_today, '2022', 700, type: TextInputType.number),

              // Fuel type
              _sectionTitle('⛽ Combustível', 800),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 8, children: _fuels.map((f) {
                final sel = _fuelType == f['value'];
                return GestureDetector(
                  onTap: () => setState(() => _fuelType = f['value'] as String),
                  child: AnimatedContainer(
                    duration: 200.ms,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.primary.withOpacity(0.2) : AppColors.bgCardLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: sel ? AppColors.primary : Colors.white.withOpacity(0.08)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(f['icon'] as IconData, size: 18, color: sel ? AppColors.neonCyan : AppColors.textTertiary),
                      const SizedBox(width: 6),
                      Text(f['label'] as String, style: TextStyle(fontSize: 13, color: sel ? AppColors.textPrimary : AppColors.textSecondary)),
                    ]),
                  ),
                );
              }).toList()).animate().fadeIn(delay: 800.ms),

              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: _input('Consumo (km/l)', _consumptionCtrl, Icons.speed, isMoto ? '35' : '12', 900, type: TextInputType.number)),
                const SizedBox(width: 12),
                Expanded(child: _input('R\$/litro', _fuelPriceCtrl, Icons.attach_money, '5.89', 1000, type: TextInputType.number)),
              ]),

              // Cost Preview
              if (_consumptionCtrl.text.isNotEmpty && _fuelPriceCtrl.text.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [AppColors.primary.withOpacity(0.15), AppColors.neonCyan.withOpacity(0.08)]),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calculate, color: AppColors.neonCyan),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Custo por km', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                      Text('R\$ ${_calcCostPerKm()}', style: const TextStyle(color: AppColors.neonCyan, fontSize: 20, fontWeight: FontWeight.w700)),
                    ]),
                  ]),
                ),

              // Goals
              _sectionTitle('🎯 Metas', 1100),
              const SizedBox(height: 16),
              _input('Meta diária (R\$)', _dailyGoalCtrl, Icons.today, isMoto ? '150' : '200', 1200, type: TextInputType.number),
              _input('Meta semanal (R\$)', _weeklyGoalCtrl, Icons.date_range, isMoto ? '750' : '1000', 1300, type: TextInputType.number),
              _input('Meta mensal (R\$)', _monthlyGoalCtrl, Icons.calendar_month, isMoto ? '3000' : '4000', 1400, type: TextInputType.number),

              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 56, child: Container(
                decoration: BoxDecoration(gradient: AppColors.primaryGradient, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 8))]),
                child: ElevatedButton(
                  onPressed: _loading ? null : _handleSave,
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: _loading
                    ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Salvar e continuar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              )).animate().fadeIn(delay: 1500.ms),

              const SizedBox(height: 32),
            ])),
          ),
        ),
      ),
    );
  }

  Widget _vehicleTypeCard(String value, String emoji, String label, int delay) {
    final selected = _vehicleType == value;
    return GestureDetector(
      onTap: () => setState(() => _vehicleType = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.15) : AppColors.bgCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.white.withOpacity(0.08),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 16)] : [],
        ),
        child: Column(children: [
          Text(emoji, style: const TextStyle(fontSize: 36)),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
            fontSize: 16, fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          )),
          if (selected) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
              child: const Text('Selecionado', style: TextStyle(color: AppColors.neonCyan, fontSize: 11, fontWeight: FontWeight.w600)),
            ),
          ],
        ]),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay)).scale(begin: const Offset(0.95, 0.95));
  }

  String _calcCostPerKm() {
    final c = double.tryParse(_consumptionCtrl.text) ?? 0;
    final p = double.tryParse(_fuelPriceCtrl.text) ?? 0;
    return c > 0 ? (p / c).toStringAsFixed(2) : '0.00';
  }

  Widget _sectionTitle(String text, int delay) => Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.textPrimary)).animate().fadeIn(delay: Duration(milliseconds: delay));

  Widget _input(String label, TextEditingController ctrl, IconData icon, String hint, int delay, {TextInputType type = TextInputType.text}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
      const SizedBox(height: 8),
      TextFormField(
        controller: ctrl, keyboardType: type,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(hintText: hint, prefixIcon: Icon(icon, color: AppColors.textTertiary, size: 20)),
      ).animate().fadeIn(delay: Duration(milliseconds: delay)),
      const SizedBox(height: 16),
    ]);
  }

  void _handleSave() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) { setState(() => _loading = false); context.go('/permissions-setup'); }
  }
}
