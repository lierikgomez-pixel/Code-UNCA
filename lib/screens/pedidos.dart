import 'package:flutter/material.dart';
import '../models.dart';
import '../payments.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets.dart';

const _presets = ['Limón persa', 'Limón mexicano'];

class PedidosScreen extends StatelessWidget {
  const PedidosScreen({super.key});

  Future<void> _addProduct(BuildContext context, {String name = ''}) async {
    final nameC = TextEditingController(text: name);
    final price = TextEditingController();
    var unit = 'kg';
    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: AppColors.bosqueProfundo,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: const Text('Producto de limón'),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              TextField(
                controller: nameC,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(labelText: 'Nombre (ej. Limón persa)'),
              ),
              const SizedBox(height: 12),
              const Text('Se vende por:'),
              Wrap(spacing: 8, children: [
                for (final u in units)
                  ChoiceChip(label: Text(u), selected: unit == u, onSelected: (_) => setS(() => unit = u)),
              ]),
              const SizedBox(height: 12),
              TextField(
                controller: price,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(labelText: 'Precio por $unit', prefixText: '\$ '),
              ),
            ]),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
            FilledButton(
              onPressed: () {
                final p = double.tryParse(price.text.replaceAll(',', '.'));
                if (nameC.text.trim().isEmpty || p == null || p <= 0) return;
                store.addProduct(nameC.text.trim(), unit, p);
                Navigator.pop(ctx);
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _newOrder(BuildContext context) async {
    final order = await showModalBottomSheet<Order>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.bosqueProfundo,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (_) => const _NewOrderSheet(),
    );
    if (order == null || !context.mounted) return;
    store.addOrder(order);
    _charge(context, order);
  }

  void _charge(BuildContext context, Order o) {
    startPayment(context,
        amount: o.total,
        ref: o.id,
        concept: 'Pedido de ${o.customer}: ${o.summary}',
        onPaid: (m) => store.markOrderPaid(o.id, method: m.key));
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) => Scaffold(
        appBar: AppBar(title: const Text('Pedidos de limón')),
        body: ListView(padding: const EdgeInsets.fromLTRB(20, 8, 20, 24), children: [
          PillButton(
            label: 'Nuevo pedido',
            icon: Icons.shopping_basket_outlined,
            filled: true,
            onPressed: store.products.isEmpty ? null : () => _newOrder(context),
          ),
          const SizedBox(height: 24),
          const Text('Mis productos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final p in _presets)
              ActionChip(label: Text('+ $p'), onPressed: () => _addProduct(context, name: p)),
            ActionChip(label: const Text('+ Otro'), onPressed: () => _addProduct(context)),
          ]),
          const SizedBox(height: 8),
          if (store.products.isEmpty)
            const Panel(child: Text('Agrega tu limón con su unidad y precio para empezar a tomar pedidos.')),
          for (final p in store.products)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Panel(
                padding: const EdgeInsets.fromLTRB(16, 6, 6, 6),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                      Text('${mxn(p.price)} por ${p.unit}', style: const TextStyle(color: Colors.white70)),
                    ]),
                  ),
                  IconButton(icon: const Icon(Icons.delete_outline), onPressed: () => store.removeProduct(p.id)),
                ]),
              ),
            ),
          const SizedBox(height: 20),
          const Text('Pedidos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (store.orders.isEmpty) const Panel(child: Text('Aún no hay pedidos.')),
          for (final o in store.orders.reversed.take(20))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Panel(
                padding: const EdgeInsets.fromLTRB(16, 10, 8, 10),
                child: Row(children: [
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${o.customer} · ${mxn(o.total)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      Text(o.summary, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ]),
                  ),
                  o.paid
                      ? const Padding(padding: EdgeInsets.all(8), child: Icon(Icons.check_circle, color: AppColors.menta))
                      : TextButton(onPressed: () => _charge(context, o), child: const Text('Cobrar')),
                ]),
              ),
            ),
        ]),
      ),
    );
  }
}

class _NewOrderSheet extends StatefulWidget {
  const _NewOrderSheet();
  @override
  State<_NewOrderSheet> createState() => _NewOrderSheetState();
}

class _NewOrderSheetState extends State<_NewOrderSheet> {
  final _customer = TextEditingController();
  final Map<String, double> _qty = {};

  double _step(Product p) => p.unit == 'kg' ? 0.5 : 1;
  double get _total => store.products.fold(0.0, (a, p) => a + p.price * (_qty[p.id] ?? 0));

  void _change(Product p, double delta) =>
      setState(() => _qty[p.id] = ((_qty[p.id] ?? 0) + delta).clamp(0.0, 999.0));

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: _customer, decoration: const InputDecoration(labelText: 'Nombre del comprador')),
        const SizedBox(height: 8),
        Flexible(
          child: ListView(shrinkWrap: true, children: [
            for (final p in store.products)
              ListTile(
                title: Text(p.name),
                subtitle: Text('${mxn(p.price)} por ${p.unit}'),
                trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                  IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => _change(p, -_step(p))),
                  SizedBox(
                    width: 64,
                    child: Text('${fmtQty(_qty[p.id] ?? 0)} ${p.unit}',
                        textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ),
                  IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => _change(p, _step(p))),
                ]),
              ),
          ]),
        ),
        const SizedBox(height: 8),
        PillButton(
          label: 'Crear y cobrar ${mxn(_total)}',
          icon: Icons.qr_code_2,
          filled: true,
          onPressed: _total <= 0
              ? null
              : () {
                  final lines = [
                    for (final p in store.products)
                      if ((_qty[p.id] ?? 0) > 0)
                        OrderLine(name: p.name, unit: p.unit, price: p.price, qty: _qty[p.id]!),
                  ];
                  final name = _customer.text.trim().isEmpty ? 'Comprador' : _customer.text.trim();
                  Navigator.pop(context, Order(id: store.newId(), customer: name, lines: lines));
                },
        ),
      ]),
    );
  }
}
