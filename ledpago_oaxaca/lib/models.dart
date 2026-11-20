String mxn(double v) {
  final parts = v.toStringAsFixed(2).split('.');
  final entero = parts[0].replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  return '\$$entero.${parts[1]}';
}

String fmtQty(double q) => q == q.roundToDouble() ? q.toInt().toString() : q.toStringAsFixed(1);

/// Unidades en las que se vende el limón.
const units = ['kg', 'costal', 'caja', 'bolsa'];

class Product {
  final String id;
  final String name;
  final String unit;
  final double price; // precio por unidad
  Product({required this.id, required this.name, required this.unit, required this.price});

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'unit': unit, 'price': price};
  factory Product.fromJson(Map<String, dynamic> j) => Product(
        id: j['id'],
        name: j['name'],
        unit: j['unit'] ?? 'kg',
        price: (j['price'] as num).toDouble(),
      );
}

class Sale {
  final String id;
  final double amount;
  final String method; // 'QR' o 'Efectivo'
  final String note;
  final DateTime date;
  Sale({required this.id, required this.amount, required this.method, this.note = '', DateTime? date})
      : date = date ?? DateTime.now();

  bool get digital => method != 'Efectivo';

  Map<String, dynamic> toJson() =>
      {'id': id, 'amount': amount, 'method': method, 'note': note, 'date': date.toIso8601String()};
  factory Sale.fromJson(Map<String, dynamic> j) => Sale(
        id: j['id'],
        amount: (j['amount'] as num).toDouble(),
        method: j['method'],
        note: j['note'] ?? '',
        date: DateTime.parse(j['date']),
      );
}

class OrderLine {
  final String name;
  final String unit;
  final double price;
  final double qty;
  OrderLine({required this.name, required this.unit, required this.price, required this.qty});

  Map<String, dynamic> toJson() => {'name': name, 'unit': unit, 'price': price, 'qty': qty};
  factory OrderLine.fromJson(Map<String, dynamic> j) => OrderLine(
        name: j['name'],
        unit: j['unit'] ?? 'kg',
        price: (j['price'] as num).toDouble(),
        qty: (j['qty'] as num).toDouble(),
      );
}

class Order {
  final String id;
  final String customer;
  final List<OrderLine> lines;
  bool paid;
  final DateTime date;
  Order({required this.id, required this.customer, required this.lines, this.paid = false, DateTime? date})
      : date = date ?? DateTime.now();

  double get total => lines.fold(0.0, (a, l) => a + l.price * l.qty);
  String get summary => lines.map((l) => '${fmtQty(l.qty)} ${l.unit} de ${l.name}').join(', ');

  Map<String, dynamic> toJson() => {
        'id': id,
        'customer': customer,
        'lines': lines.map((l) => l.toJson()).toList(),
        'paid': paid,
        'date': date.toIso8601String(),
      };
  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'],
        customer: j['customer'],
        lines: (j['lines'] as List).map((e) => OrderLine.fromJson(Map<String, dynamic>.from(e))).toList(),
        paid: j['paid'],
        date: DateTime.parse(j['date']),
      );
}
