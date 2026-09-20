import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/models.dart';

class AppStore extends ChangeNotifier {
  static const _kCustomers = 'customers';
  static const _kTransactions = 'transactions';

  final List<Customer> _customers = [];
  final List<Transaction> _transactions = [];
  bool _loaded = false;

  List<Customer> get customers => List.unmodifiable(_customers);

  List<Transaction> get transactions => List.unmodifiable(_transactions);

  Future<void> load() async {
    if (_loaded) return;
    final prefs = await SharedPreferences.getInstance();

    final cj = prefs.getString(_kCustomers);
    if (cj != null) {
      try {
        _customers
          ..clear()
          ..addAll((jsonDecode(cj) as List)
              .map((e) => Customer.fromJson(e as Map<String, dynamic>)));
      } catch (_) {}
    }

    final tj = prefs.getString(_kTransactions);
    if (tj != null) {
      try {
        _transactions
          ..clear()
          ..addAll((jsonDecode(tj) as List)
              .map((e) => Transaction.fromJson(e as Map<String, dynamic>)));
      } catch (_) {}
    }

    _loaded = true;
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _kCustomers, jsonEncode(_customers.map((c) => c.toJson()).toList()));
    await prefs.setString(_kTransactions,
        jsonEncode(_transactions.map((t) => t.toJson()).toList()));
  }

  Future<void> addCustomer(Customer customer) async {
    _customers.add(customer);
    notifyListeners();
    await _save();
  }

  Future<void> addTransaction(Transaction transaction) async {
    _transactions.add(transaction);
    notifyListeners();
    await _save();
  }

  Customer? customerById(String id) {
    for (final c in _customers) {
      if (c.id == id) return c;
    }
    return null;
  }

  List<Transaction> customerTransactions(String customerId) {
    return _transactions.where((t) => t.customerId == customerId).toList();
  }

  /// Mijozning umumiy qarzi (barcha yozuvlar bo'yicha).
  int customerDebt(String customerId) {
    return customerTransactions(customerId).fold(0, (s, t) => s + t.debt);
  }
}