import 'dart:math';

class Product {
  const Product({required this.id, required this.name});

  final String id;
  final String name;
}

const List<Product> kProducts = [
  Product(id: 'meter', name: '1 Metrli'),
  Product(id: 'sixfive', name: '6.5 li'),
  Product(id: 'shell', name: "Chig'anoq"),
  Product(id: 'thirty', name: '30 sm li'),
];

Product productById(String id) {
  return kProducts.firstWhere((p) => p.id == id, orElse: () => kProducts.first);
}

String newId() {
  final r = Random();
  return '${DateTime.now().microsecondsSinceEpoch}${r.nextInt(9000) + 1000}';
}

class Customer {
  const Customer({required this.id, required this.name, required this.phone});

  final String id;
  final String name;
  final String phone;

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'phone': phone};

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
        id: json['id'] as String,
        name: json['name'] as String,
        phone: (json['phone'] as String?) ?? '',
      );
}

class SaleItem {
  const SaleItem({
    required this.productId,
    required this.productName,
    this.price = 0,
    this.quantity = 0,
  });

  final String productId;
  final String productName;
  final int price;
  final int quantity;

  int get total => price * quantity;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
      };

  factory SaleItem.fromJson(Map<String, dynamic> json) => SaleItem(
        productId: json['productId'] as String,
        productName: json['productName'] as String,
        price: (json['price'] as num?)?.toInt() ?? 0,
        quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      );
}

class Transaction {
  const Transaction({
    required this.id,
    required this.customerId,
    required this.customerName,
    required this.date,
    required this.items,
    required this.amount,
    required this.paid,
  });

  final String id;
  final String customerId;
  final String customerName;
  final DateTime date;
  final List<SaleItem> items;

  /// Qiymati (mahsulotlar summasi). Toza qarz to'lovida 0 bo'ladi.
  final int amount;

  /// Mijozdan olingan pul.
  final int paid;

  /// Bu yozuv bo'yicha qarz.
  int get debt => amount - paid;

  /// Sof qarz to'lovi yozuvimi?
  bool get isPaymentOnly => items.isEmpty;

  int get itemsTotal => items.fold(0, (s, i) => s + i.total);

  Map<String, dynamic> toJson() => {
        'id': id,
        'customerId': customerId,
        'customerName': customerName,
        'date': date.toIso8601String(),
        'items': items.map((i) => i.toJson()).toList(),
        'amount': amount,
        'paid': paid,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        customerId: json['customerId'] as String,
        customerName: json['customerName'] as String,
        date: DateTime.parse(json['date'] as String),
        items: ((json['items'] as List?) ?? [])
            .map((e) => SaleItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        amount: (json['amount'] as num?)?.toInt() ?? 0,
        paid: (json['paid'] as num?)?.toInt() ?? 0,
      );
}