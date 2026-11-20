import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'models.dart';
import 'store.dart';
import 'theme.dart';
import 'widgets.dart';

/// Métodos de pago al estilo de las apps de cobro (QR, transferencia, link, tarjeta, efectivo).
enum PayMethod {
  qr('QR', 'QR', Icons.qr_code_2, 'El comprador escanea desde su app'),
  spei('SPEI', 'Transferencia', Icons.account_balance_outlined, 'Transferencia a tu CLABE'),
  link('Link', 'Link de pago', Icons.link, 'Envía el cobro por mensaje'),
  tarjeta('Tarjeta', 'Tarjeta', Icons.credit_card, 'Débito o crédito en tu terminal'),
  efectivo('Efectivo', 'Efectivo', Icons.payments_outlined, 'Dinero en mano, con cálculo de cambio');

  const PayMethod(this.key, this.label, this.icon, this.hint);
  final String key; // se guarda en cada venta
  final String label;
  final IconData icon;
  final String hint;

  bool get digital => this != PayMethod.efectivo;

  static PayMethod fromKey(String k) =>
      PayMethod.values.firstWhere((m) => m.key == k, orElse: () => PayMethod.qr);
}

String _shortRef(String ref) => 'LIM${ref.length > 6 ? ref.substring(ref.length - 6) : ref}';

/// Pregunta cómo paga el comprador y corre el flujo de ese método.
/// [onPaid] se llama cuando el comerciante confirma que ya recibió el pago.
Future<void> startPayment(
  BuildContext context, {
  required double amount,
  required String ref,
  required String concept,
  required void Function(PayMethod) onPaid,
}) async {
  final m = await showModalBottomSheet<PayMethod>(
    context: context,
    backgroundColor: AppColors.bosqueProfundo,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (ctx) => SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('¿Cómo te paga?', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          Text(mxn(amount), style: const TextStyle(fontSize: 18, color: AppColors.limon, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          for (final method in PayMethod.values)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: AppColors.limon,
                child: Icon(method.icon, color: AppColors.bosqueProfundo),
              ),
              title: Text(method.label, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(method.hint, style: const TextStyle(color: Colors.white70)),
              onTap: () => Navigator.pop(ctx, method),
            ),
        ]),
      ),
    ),
  );
  if (m == null || !context.mounted) return;

  switch (m) {
    case PayMethod.qr:
      await showPayQr(context, amount: amount, ref: ref, concept: concept, onPaid: () => onPaid(m));
    case PayMethod.spei:
      await _speiDialog(context, amount, ref, () => onPaid(m));
    case PayMethod.link:
      await _linkDialog(context, amount, ref, concept, () => onPaid(m));
    case PayMethod.tarjeta:
      await _confirmDialog(
        context,
        amount: amount,
        body: Text('Cobra ${mxn(amount)} en tu terminal o lector de tarjetas. '
            'Cuando salga aprobado, confirma aquí para registrar la venta.'),
        confirmLabel: 'Ya cobré',
        onConfirm: () => onPaid(m),
      );
    case PayMethod.efectivo:
      await showDialog(context: context, builder: (_) => _CashDialog(amount: amount, onPaid: () => onPaid(m)));
  }
}

Widget _title(double amount) => Text(
      mxn(amount),
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 34, fontWeight: FontWeight.w900, color: AppColors.limon),
    );

Future<void> _confirmDialog(
  BuildContext context, {
  required double amount,
  required Widget body,
  required String confirmLabel,
  required VoidCallback? onConfirm,
}) =>
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bosqueProfundo,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: _title(amount),
        content: SingleChildScrollView(child: body),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: onConfirm == null
                ? null
                : () {
                    onConfirm();
                    Navigator.pop(ctx);
                  },
            child: Text(confirmLabel),
          ),
        ],
      ),
    );

Future<void> _speiDialog(BuildContext context, double amount, String ref, VoidCallback onPaid) {
  final clabe = store.accountRef.replaceAll(RegExp(r'\s'), '');
  final valid = RegExp(r'^\d{18}$').hasMatch(clabe);
  final concepto = _shortRef(ref);
  return _confirmDialog(
    context,
    amount: amount,
    confirmLabel: 'Ya llegó',
    onConfirm: valid ? onPaid : null,
    body: valid
        ? Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('CLABE', style: TextStyle(color: Colors.white70)),
            SelectableText(clabe, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text('Beneficiario: ${store.businessName}'),
            Text('Concepto: $concepto'),
            const SizedBox(height: 4),
            Builder(
              builder: (ctx) => TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: clabe));
                  snack(ctx, 'CLABE copiada');
                },
                icon: const Icon(Icons.copy, size: 18),
                label: const Text('Copiar CLABE'),
              ),
            ),
            const Text('Confirma solo cuando veas el depósito en tu banco.',
                style: TextStyle(fontSize: 13, color: Colors.white70)),
          ])
        : const Text('Para recibir transferencias, guarda tu CLABE de 18 dígitos en Mi negocio '
            '(el engrane en la pantalla Cobrar).'),
  );
}

Future<void> _linkDialog(BuildContext context, double amount, String ref, String concept, VoidCallback onPaid) {
  final mensaje = 'Hola, te comparto el cobro de ${mxn(amount)} por $concept a ${store.businessName}: '
      '${store.paymentPayload(amount, ref)}';
  return _confirmDialog(
    context,
    amount: amount,
    confirmLabel: 'Ya me pagaron',
    onConfirm: onPaid,
    body: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Copia este mensaje y mándalo por WhatsApp o SMS:'),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppColors.campo, borderRadius: BorderRadius.circular(14)),
        child: SelectableText(mensaje, style: const TextStyle(fontSize: 13)),
      ),
      Builder(
        builder: (ctx) => TextButton.icon(
          onPressed: () {
            Clipboard.setData(ClipboardData(text: mensaje));
            snack(ctx, 'Mensaje copiado');
          },
          icon: const Icon(Icons.copy, size: 18),
          label: const Text('Copiar mensaje'),
        ),
      ),
      const Text('Este link es de ejemplo: todavía no abre una página de pago real.',
          style: TextStyle(fontSize: 13, color: Colors.white70)),
    ]),
  );
}

class _CashDialog extends StatefulWidget {
  final double amount;
  final VoidCallback onPaid;
  const _CashDialog({required this.amount, required this.onPaid});
  @override
  State<_CashDialog> createState() => _CashDialogState();
}

class _CashDialogState extends State<_CashDialog> {
  final _paid = TextEditingController();
  double? get _v => double.tryParse(_paid.text.replaceAll(',', '.'));

  @override
  Widget build(BuildContext context) {
    final v = _v;
    final cambio = (v ?? 0) - widget.amount;
    return AlertDialog(
      backgroundColor: AppColors.bosqueProfundo,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      title: _title(widget.amount),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(
          controller: _paid,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(labelText: 'El comprador paga con', prefixText: '\$ '),
        ),
        const SizedBox(height: 12),
        if (v != null)
          Text(
            cambio >= 0 ? 'Cambio: ${mxn(cambio)}' : 'Faltan ${mxn(-cambio)}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: cambio >= 0 ? AppColors.menta : const Color(0xFFFF8A80),
            ),
          ),
      ]),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
        FilledButton(
          onPressed: (v != null && cambio < 0)
              ? null
              : () {
                  widget.onPaid();
                  Navigator.pop(context);
                },
          child: const Text('Cobrado'),
        ),
      ],
    );
  }
}
