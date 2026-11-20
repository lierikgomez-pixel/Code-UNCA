import 'package:flutter/material.dart';
import '../models.dart';
import '../payments.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

/// Metas informativas tomadas de la propuesta del proyecto.
/// Verifica las cifras vigentes con Banxico o tu banco antes de mostrarlas al público.
const double _metaDigitalMensual = 105000;
const double _topeMensual = 130000;

class AprenderScreen extends StatelessWidget {
  const AprenderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        final progreso = (store.monthDigital / _metaDigitalMensual).clamp(0.0, 1.0);
        return Scaffold(
          appBar: AppBar(
        leading: const Padding(
          padding: EdgeInsets.all(8),
          child: BrandLogo(size: 30),
        ),
        title: const Text('Aprender y crecer'),
      ),
          body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
            Panel(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Tu camino a la Cuenta Nivel 2 Bis',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 14),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progreso,
                    minHeight: 14,
                    color: AppColors.limon,
                    backgroundColor: Colors.white24,
                  ),
                ),
                const SizedBox(height: 10),
                Text('${mxn(store.monthDigital)} cobrados con QR este mes de ${mxn(_metaDigitalMensual)}'),
                const SizedBox(height: 4),
                Text('Tope mensual de la cuenta: ${mxn(_topeMensual)}',
                    style: const TextStyle(fontSize: 13, color: Colors.white70)),
              ]),
            ),
            const SizedBox(height: 16),
            if (store.monthByMethod.isNotEmpty) ...[
              Panel(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Cobros del mes por método',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 10),
                  for (final e in store.monthByMethod.entries)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(children: [
                        Icon(PayMethod.fromKey(e.key).icon, color: AppColors.limon, size: 20),
                        const SizedBox(width: 10),
                        Expanded(child: Text(PayMethod.fromKey(e.key).label)),
                        Text(mxn(e.value), style: const TextStyle(fontWeight: FontWeight.w700)),
                      ]),
                    ),
                ]),
              ),
              const SizedBox(height: 16),
            ],
            const _Tip(Icons.gavel, 'La ley no te obliga',
                'Busca que más negocios acepten pagos digitales. No prohíbe el efectivo.'),
            const _Tip(Icons.money_off, 'Cobra sin comisión',
                'CoDi y DiMo cobran desde el celular del comprador. Confirma condiciones con tu banco.'),
            const _Tip(Icons.history, 'Cada venta cuenta',
                'Cada venta de limón con QR queda registrada y te ayuda a acceder a mejores cuentas.'),
            const _Tip(Icons.scale_outlined, 'Vende por kilo, costal o caja',
                'Registra cada pedido con su unidad y precio del día para llevar tus kilos al corriente.'),
            const _Tip(Icons.groups, 'Pide un taller',
                'Busca talleres con otros productores y promotores que te acompañen en tus primeros cobros.'),
          ]),
        );
      },
    );
  }
}

class _Tip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _Tip(this.icon, this.title, this.body);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Panel(
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, size: 30, color: AppColors.limon),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                const SizedBox(height: 2),
                Text(body, style: const TextStyle(color: Colors.white70)),
              ]),
            ),
          ]),
        ),
      );
}
