import 'package:flutter/material.dart';

import '../models.dart';
import '../payments.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

class CobrarScreen extends StatefulWidget {
  const CobrarScreen({super.key});
  @override
  State<CobrarScreen> createState() => _CobrarScreenState();
}

class _CobrarScreenState extends State<CobrarScreen> {
  final _amount = TextEditingController();
  final _concept = TextEditingController();

  double? get _value => double.tryParse(_amount.text.replaceAll(',', '.'));

  void _cobrar() {
    final v = _value;
    if (v == null || v <= 0) return snack(context, 'Escribe un monto válido');
    final ref = store.newId();
    final concept = _concept.text.trim().isEmpty
        ? 'Venta de limón'
        : _concept.text.trim();
    startPayment(
      context,
      amount: v,
      ref: ref,
      concept: concept,
      onPaid: (m) {
        store.addSale(Sale(id: ref, amount: v, method: m.key, note: concept));
        _amount.clear();
        _concept.clear();
      },
    );
  }

  Future<void> _settings() async {
    final name = TextEditingController(text: store.businessName);
    final ref = TextEditingController(text: store.accountRef);
    final banco = TextEditingController(text: store.bankName);
    final clabe = TextEditingController(text: store.bankClabe);
    final titular = TextEditingController(text: store.bankHolder);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bosqueProfundo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('CODI-UNCA'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: name,
                decoration: const InputDecoration(
                  labelText: 'Nombre del negocio',
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ref,
                decoration: const InputDecoration(
                  labelText: 'Celular o CLABE para cobrar',
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Datos bancarios (simulación)',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppColors.limon,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Solo demostración. No escribas datos reales.',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: banco,
                decoration: const InputDecoration(labelText: 'Banco'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: clabe,
                decoration: const InputDecoration(
                  labelText: 'CLABE (simulación)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: titular,
                decoration: const InputDecoration(labelText: 'Titular'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              store.setBusiness(name.text, ref.text);
              store.setBankData(
                banco: banco.text,
                clabe: clabe.text,
                titular: titular.text,
              );
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final recent = store.sales.reversed.take(8).toList();
        return Scaffold(
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              children: [
                Row(
                  children: [
                    const BrandLogo(size: 34),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            store.businessName.isEmpty ? 'CODI-UNCA' : store.businessName,
                            style: const TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          const Text(
                            'OAXACA -SIERRA DE FLORES MAGÓN',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _settings,
                      icon: const Icon(Icons.settings_outlined),
                      tooltip: 'Datos del negocio',
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.limon,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Text(
                            '${store.todayCount}',
                            style: const TextStyle(
                              color: AppColors.bosqueProfundo,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.receipt_long,
                            size: 18,
                            color: AppColors.bosqueProfundo,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const HeroTitle(
                  kicker: 'OAXACA -SIERRA DE FLORES MAGÓN',
                  title: 'CODI-UNCA',
                  subtitle: 'Comercio digital del limón.',
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: _Stat('Vendido hoy', mxn(store.todayTotal)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _Stat(
                        'Kilos del mes',
                        '${fmtQty(store.monthKg)} kg',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _amount,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w700,
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Monto a cobrar',
                    prefixText: '\$ ',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _concept,
                  decoration: const InputDecoration(
                    labelText: 'Concepto (opcional)',
                  ),
                ),
                const SizedBox(height: 18),
                PillButton(
                  label: 'Cobrar',
                  icon: Icons.arrow_forward,
                  filled: true,
                  onPressed: _cobrar,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Últimas ventas',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                if (recent.isEmpty)
                  const Panel(child: Text('Aún no hay ventas.')),
                for (final s in recent)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Panel(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            PayMethod.fromKey(s.method).icon,
                            color: AppColors.limon,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  mxn(s.amount),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  '${PayMethod.fromKey(s.method).label}${s.note.isEmpty ? '' : ' · ${s.note}'}',
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat(this.label, this.value);

  @override
  Widget build(BuildContext context) => Panel(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    ),
  );
}
