import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/store.dart';
import '../widgets/customer_card.dart';
import 'add_customer_screen.dart';
import 'customer_screen.dart';
import 'history_screen.dart';
import 'search_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key, required this.store});

  final AppStore store;

  Future<void> _editCustomer(BuildContext context, Customer c) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AddCustomerScreen(store: store, customer: c),
      ),
    );
  }

  Future<void> _deleteCustomer(BuildContext context, Customer c) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.delete_forever_rounded,
            size: 54, color: Color(0xFFC62828)),
        title: const Text('MIJOZNI O\'CHIRISH', style: TextStyle(fontSize: 24)),
        content: Text(
          '${c.name}\n\nBu mijoz va uning barcha savdo yozuvlari o\'chiriladi. Ishonchingiz komilmi?',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, height: 1.4),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('YO\'Q', style: TextStyle(fontSize: 22)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size(140, 56),
              backgroundColor: const Color(0xFFC62828),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('O\'CHIRISH', style: TextStyle(fontSize: 20)),
          ),
        ],
      ),
    );
    if (ok == true) await store.deleteCustomer(c.id);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('MIJOZLAR'),
        actions: [
          IconButton(
            iconSize: 34,
            tooltip: 'Qidirish',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => SearchScreen(store: store)),
            ),
            icon: const Icon(Icons.search_rounded),
          ),
          IconButton(
            iconSize: 34,
            tooltip: 'Tarix',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => HistoryScreen(store: store)),
            ),
            icon: const Icon(Icons.history_rounded),
          ),
          IconButton(
            iconSize: 34,
            tooltip: 'Mijoz qo\'shish',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (_) => AddCustomerScreen(store: store)),
            ),
            icon: const Icon(Icons.person_add_alt_1_rounded),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final customers = store.customers;
          if (customers.isEmpty) return _EmptyState(store: store);
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: customers.length,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (context, i) {
              final c = customers[i];
              return CustomerCard(
                customer: c,
                debt: store.customerDebt(c.id),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => CustomerScreen(store: store, customer: c)),
                ),
                onEdit: () => _editCustomer(context, c),
                onDelete: () => _deleteCustomer(context, c),
              );
            },
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.group_rounded, size: 96, color: Color(0xFFB0BEC5)),
            const SizedBox(height: 20),
            const Text(
              'Mijozlar hali yo\'q',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            const Text(
              'O\'ngdagi ➕ tugmasini bosib\nbirinchi mijozni qo\'shing',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 20, color: Color(0xFF607D8B), height: 1.4),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size(260, 64),
                backgroundColor: const Color(0xFF106B66),
              ),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => AddCustomerScreen(store: store)),
              ),
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 30),
              label: const Text('MIJOZ QO\'SHISH',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}