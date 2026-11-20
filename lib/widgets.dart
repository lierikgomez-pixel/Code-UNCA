import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'models.dart';
import 'store.dart';
import 'theme.dart';

/// Logo institucional reutilizable en toda la app.
class BrandLogo extends StatelessWidget {
  final double size;
  const BrandLogo({super.key, this.size = 34});

  @override
  Widget build(BuildContext context) => Image.asset(
        'assets/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      );
}

/// Tarjeta oscura translúcida.
class Panel extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const Panel({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(22)),
        child: child,
      );
}

/// Botón tipo píldora con círculo amarillo, como en el diseño de referencia.
class PillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool filled;
  const PillButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled ? AppColors.limon : Colors.transparent;
    final fg = filled ? AppColors.bosqueProfundo : Colors.white;
    return Opacity(
      opacity: onPressed == null ? 0.5 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: onPressed,
        child: Container(
          height: 58,
          padding: const EdgeInsets.fromLTRB(24, 6, 6, 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: AppColors.limon, width: 1.6),
          ),
          child: Row(children: [
            Expanded(child: Text(label, style: TextStyle(color: fg, fontSize: 17, fontWeight: FontWeight.w700))),
            CircleAvatar(
              radius: 22,
              backgroundColor: filled ? AppColors.bosqueProfundo : AppColors.limon,
              child: Icon(icon, color: filled ? AppColors.limon : AppColors.bosqueProfundo),
            ),
          ]),
        ),
      ),
    );
  }
}

/// Titular grande al estilo del diseño de referencia.
class HeroTitle extends StatelessWidget {
  final String kicker;
  final String title;
  final String subtitle;
  const HeroTitle({super.key, required this.kicker, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const BrandLogo(size: 54),
        const SizedBox(height: 12),
        Text(kicker, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, letterSpacing: 3)),
        Text(title,
            style: const TextStyle(fontSize: 68, fontWeight: FontWeight.w900, height: 1.0, letterSpacing: -1)),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(fontSize: 16, height: 1.3)),
      ]);
}

/// Muestra el QR de cobro. [onPaid] se llama cuando el comerciante confirma el pago.
Future<void> showPayQr(
  BuildContext context, {
  required double amount,
  required String ref,
  required String concept,
  required VoidCallback onPaid,
}) {
  return showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.bosqueProfundo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: Text(mxn(amount),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.limon)),
      content: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text(concept, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.all(10),
            child: QrImageView(data: store.paymentPayload(amount, ref), size: 230),
          ),
          const SizedBox(height: 8),
          const Text('Pídele al cliente que escanee el código desde su app.', textAlign: TextAlign.center),
        ]),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        FilledButton(
          onPressed: () {
            onPaid();
            Navigator.pop(ctx);
          },
          child: const Text('Ya me pagaron'),
        ),
      ],
    ),
  );
}

void snack(BuildContext context, String msg) =>
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
