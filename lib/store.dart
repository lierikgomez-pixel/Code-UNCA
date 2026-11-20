import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Estado local de la app. Todo se guarda en el teléfono (offline-first).
class AppStore extends ChangeNotifier {
  SharedPreferences? _p;
  String businessName = 'Mi negocio';
  String accountRef = ''; // CLABE o celular ligado a CoDi/DiMo

  // Datos bancarios de demostración. NUNCA guardes datos reales aquí.
  String bankName = '';
  String bankClabe = '';
  String bankHolder = '';

  // Contexto de la última foto analizada, para que el asistente lo use.
  String lastPhotoClase = '';
  double lastPhotoConfianza = 0;
  bool lastPhotoDudoso = false;

  List<Product> products = [];
  List<Sale> sales = [];
  List<Order> orders = [];

  Future<void> load() async {
    _p = await SharedPreferences.getInstance();
    businessName = _p!.getString('businessName') ?? businessName;
    accountRef = _p!.getString('accountRef') ?? '';
    bankName = _p!.getString('bankName') ?? '';
    bankClabe = _p!.getString('bankClabe') ?? '';
    bankHolder = _p!.getString('bankHolder') ?? '';
    lastPhotoClase = _p!.getString('lastPhotoClase') ?? '';
    lastPhotoConfianza = _p!.getDouble('lastPhotoConfianza') ?? 0;
    lastPhotoDudoso = _p!.getBool('lastPhotoDudoso') ?? false;
    products = _read('products', Product.fromJson);
    sales = _read('sales', Sale.fromJson);
    orders = _read('orders', Order.fromJson);
  }

  List<T> _read<T>(String key, T Function(Map<String, dynamic>) f) {
    final raw = _p?.getString(key);
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => f(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return []; // datos viejos con otro formato
    }
  }

  Future<void> _save() async {
    final p = _p;
    if (p == null) return;
    await p.setString('businessName', businessName);
    await p.setString('accountRef', accountRef);
    await p.setString('bankName', bankName);
    await p.setString('bankClabe', bankClabe);
    await p.setString('bankHolder', bankHolder);
    await p.setString('lastPhotoClase', lastPhotoClase);
    await p.setDouble('lastPhotoConfianza', lastPhotoConfianza);
    await p.setBool('lastPhotoDudoso', lastPhotoDudoso);
    await p.setString(
      'products',
      jsonEncode(products.map((e) => e.toJson()).toList()),
    );
    await p.setString(
      'sales',
      jsonEncode(sales.map((e) => e.toJson()).toList()),
    );
    await p.setString(
      'orders',
      jsonEncode(orders.map((e) => e.toJson()).toList()),
    );
  }

  void _commit() {
    notifyListeners();
    _save();
  }

  String newId() => DateTime.now().microsecondsSinceEpoch.toString();

  void setBusiness(String name, String ref) {
    businessName = name.trim().isEmpty ? 'Mi negocio' : name.trim();
    accountRef = ref.trim();
    _commit();
  }

  /// Guarda datos bancarios SOLO como simulación local.
  void setBankData({
    required String banco,
    required String clabe,
    required String titular,
  }) {
    bankName = banco.trim();
    bankClabe = clabe.trim();
    bankHolder = titular.trim();
    _commit();
  }

  /// Guarda el contexto de la última foto para que el asistente lo mencione.
  void setLastPhoto({
    required String clase,
    required double confianza,
    required bool dudoso,
  }) {
    lastPhotoClase = clase;
    lastPhotoConfianza = confianza;
    lastPhotoDudoso = dudoso;
    _commit();
  }

  void addProduct(String name, String unit, double price) {
    products.add(Product(id: newId(), name: name, unit: unit, price: price));
    _commit();
  }

  void removeProduct(String id) {
    products.removeWhere((p) => p.id == id);
    _commit();
  }

  void addSale(Sale s) {
    sales.add(s);
    _commit();
  }

  void addOrder(Order o) {
    orders.add(o);
    _commit();
  }

  void markOrderPaid(String id, {String method = 'QR'}) {
    final o = orders.firstWhere((o) => o.id == id);
    if (o.paid) return;
    o.paid = true;
    sales.add(
      Sale(
        id: newId(),
        amount: o.total,
        method: method,
        note: 'Pedido de ${o.customer}',
      ),
    );
    _commit();
  }

  bool _hoy(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month && d.day == n.day;
  }

  bool _esteMes(DateTime d) {
    final n = DateTime.now();
    return d.year == n.year && d.month == n.month;
  }

  double get todayTotal =>
      sales.where((s) => _hoy(s.date)).fold(0.0, (a, s) => a + s.amount);
  int get todayCount => sales.where((s) => _hoy(s.date)).length;

  /// Ventas digitales del mes (suman para el historial hacia la Cuenta Nivel 2 Bis).
  double get monthDigital => sales
      .where((s) => s.digital && _esteMes(s.date))
      .fold(0.0, (a, s) => a + s.amount);

  /// Total cobrado este mes por método de pago.
  Map<String, double> get monthByMethod {
    final m = <String, double>{};
    for (final s in sales.where((s) => _esteMes(s.date))) {
      m[s.method] = (m[s.method] ?? 0) + s.amount;
    }
    return m;
  }

  /// Kilos de limón vendidos este mes en pedidos pagados.
  double get monthKg => orders
      .where((o) => o.paid && _esteMes(o.date))
      .fold(
        0.0,
        (a, o) =>
            a +
            o.lines.where((l) => l.unit == 'kg').fold(0.0, (b, l) => b + l.qty),
      );

  /// Contenido del QR de cobro.
  /// OJO: es un formato propio de ejemplo, NO es un QR CoDi/DiMo real.
  /// Para cobrar de verdad hay que integrar un proveedor autorizado (ver README).
  String paymentPayload(double amount, String ref) =>
      'ledpago://cobro?v=1&neg=${Uri.encodeComponent(businessName)}'
      '&cta=${Uri.encodeComponent(accountRef)}&monto=${amount.toStringAsFixed(2)}&ref=$ref';
}

final AppStore store = AppStore();
