import 'package:flutter/material.dart';

import '../services/store.dart';
import '../widgets/customer_card.dart';
import 'customer_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.store});

  final AppStore store;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    return Scaffold(
      appBar: AppBar(title: const Text('QIDIRUV')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: TextField(
              controller: _controller,
              autofocus: true,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
              onChanged: (v) => setState(() => _query = v),
              decoration: InputDecoration(
                hintText: 'Ism yoki telefon raqami',
                hintStyle:
                    const TextStyle(fontSize: 20, color: Color(0xFFB0BEC5)),
                prefixIcon:
                    const Icon(Icons.search_rounded, size: 32),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        iconSize: 30,
                        onPressed: () {
                          _controller.clear();
                          setState(() => _query = '');
                        },
                        icon: const Icon(Icons.clear_rounded),
                      ),
              ),
            ),
          ),
          Expanded(
            child: ListenableBuilder(
              listenable: widget.store,
              builder: (context, _) {
                final all = widget.store.customers;
                final results = q.isEmpty
                    ? all
                    : all
                        .where((c) =>
                            c.name.toLowerCase().contains(q) ||
                            c.phone.toLowerCase().contains(q))
                        .toList();
                if (results.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person_search_rounded,
                            size: 80, color: Color(0xFFB0BEC5)),
                        const SizedBox(height: 14),
                        Text(
                          q.isEmpty
                              ? 'Ism yoki telefon kiriting'
                              : 'Hech narsa topilmadi',
                          style: const TextStyle(
                              fontSize: 22, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, i) {
                    final c = results[i];
                    return CustomerCard(
                      customer: c,
                      debt: widget.store.customerDebt(c.id),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) =>
                                CustomerScreen(store: widget.store, customer: c)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}