import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import 'package:flutter_application_1/models.dart';
import 'package:flutter_application_1/store.dart';

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
      title: Text(
        mxn(amount),
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(concept, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(8),
              child: QrImageView(
                data: store.paymentPayload(amount, ref),
                size: 240,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pídele al cliente que escanee el código desde su app.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(140, 48)),
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
