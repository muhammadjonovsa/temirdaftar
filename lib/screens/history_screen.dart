import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/store.dart';
import '../utils/dialogs.dart';
import '../utils/format.dart';
import '../utils/sms.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TARIX')),
      body: ListenableBuilder(
        listenable: store,
        builder: (context, _) {
          final list = [...store.transactions]..sort((a, b) {
              final byDate = b.date.compareTo(a.date);
              if (byDate != 0) return byDate;
              return b.id.compareTo(a.id);
            });
          if (list.isEmpty) {
            return const Center(
              child: Text(
                'Tarix hali bo\'sh',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, i) =>
                _HistoryTile(store: store, transaction: list[i]),
          );
        },
      ),
    );
  }
}

class _HistoryTile extends StatefulWidget {
  const _HistoryTile({required this.store, required this.transaction});

  final AppStore store;
  final Transaction transaction;

  @override
  State<_HistoryTile> createState() => _HistoryTileState();
}

class _HistoryTileState extends State<_HistoryTile> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.transaction;
    final debt = t.debt;
    final fullyPaid = debt <= 0 && !t.isPaymentOnly;
    final payment = t.isPaymentOnly;
    final phone = widget.store.customerById(t.customerId)?.phone ?? '';

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: () => setState(() => _expanded = !_expanded),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        payment ? const Color(0xFF2E7D32).withValues(alpha: 0.12)
                               : const Color(0xFF106B66).withValues(alpha: 0.12),
                    child: payment
                        ? const Icon(Icons.payments_rounded,
                            size: 28, color: Color(0xFF2E7D32))
                        : const Icon(Icons.person_rounded,
                            size: 28, color: Color(0xFF106B66)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          payment ? '${t.customerName} — Qarz to\'lovi'
                                  : t.customerName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formatDateTime(t.date),
                          style: const TextStyle(
                              fontSize: 17, color: Color(0xFF607D8B)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (payment)
                        Text(
                          money(t.paid),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF2E7D32)),
                        )
                      else if (!fullyPaid)
                        Text(
                          money(t.debt),
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFFC62828)),
                        )
                      else
                        const Text("TO'LANDI",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF2E7D32))),
                      const SizedBox(height: 2),
                      if (payment)
                        const Text('To\'lov',
                            style: TextStyle(
                                fontSize: 15, color: Color(0xFF607D8B)))
                      else if (!fullyPaid)
                        const Text('QARZ',
                            style: TextStyle(
                                fontSize: 15, color: Color(0xFFC62828)))
                      else
                        Text(money(t.amount),
                            style: const TextStyle(
                                fontSize: 16, color: Color(0xFF607D8B))),
                    ],
                  ),
                  const SizedBox(width: 6),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    size: 30,
                    color: const Color(0xFF607D8B),
                  ),
                ],
              ),
              if (_expanded) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(color: Color(0xFFE0E7E5)),
                ),
                for (final it in t.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Text(
                      '${it.productName} — ${fmt(it.quantity)} dona × ${fmt(it.price)} = ${money(it.total)}',
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w600),
                    ),
                  ),
                if (t.items.isEmpty) ...[
                  const Text(
                    'Qarz to\'lovi qabul qilindi',
                    style: TextStyle(fontSize: 19),
                  ),
                  _detailRow('To\'landi', money(t.paid), green: true),
                ] else ...[
                  const SizedBox(height: 6),
                  _detailRow('JAMI', money(t.amount)),
                  _detailRow('To\'landi', money(t.paid)),
                  if (debt > 0)
                    _detailRow('QARZ', money(debt), red: true),
                ],
                const SizedBox(height: 12),
                if (!payment) ...[
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(58),
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      if (phone.isEmpty) {
                        await showBigMessage(context,
                            'Telefon raqami kiritilmagan');
                        return;
                      }
                      final body = buildSmsText(
                        customerName: t.customerName,
                        items: t.items,
                        total: t.amount,
                        paid: t.paid,
                        date: t.date,
                      );
                      try {
                        await sendSms(phone, body);
                      } catch (_) {
                        if (context.mounted) {
                          await showBigMessage(
                              context, 'SMS ilovasi ochilmadi');
                        }
                      }
                    },
                    icon: const Icon(Icons.sms_rounded, size: 28),
                    label: const Text('SMS YUBORISH',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                  if (phone.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: Text(
                        'Telefon raqami kiritilmagan',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC62828)),
                      ),
                    ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value,
      {bool red = false, bool green = false}) {
    final color = red
        ? const Color(0xFFC62828)
        : green
            ? const Color(0xFF2E7D32)
            : const Color(0xFF37474F);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 19, fontWeight: FontWeight.w700)),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w900, color: color)),
        ],
      ),
    );
  }
}