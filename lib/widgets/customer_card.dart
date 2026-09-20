import 'package:flutter/material.dart';

import '../models/models.dart';
import '../utils/format.dart';

class CustomerCard extends StatelessWidget {
  const CustomerCard({
    super.key,
    required this.customer,
    required this.debt,
    this.onTap,
  });

  final Customer customer;
  final int debt;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final primary = const Color(0xFF106B66);
    final hasDebt = debt > 0;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: primary.withValues(alpha: 0.12),
                child: Icon(Icons.person_rounded,
                    size: 36, color: primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 23, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.phone_rounded,
                            size: 20, color: Color(0xFF607D8B)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            customer.phone.isEmpty
                                ? 'Telefon yo\'q'
                                : customer.phone,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 19,
                              color: customer.phone.isEmpty
                                  ? const Color(0xFF90A4AE)
                                  : const Color(0xFF37474F),
                              fontStyle: customer.phone.isEmpty
                                  ? FontStyle.italic
                                  : FontStyle.normal,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (hasDebt) ...[
                    const Text('QARZ:',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFC62828))),
                    const SizedBox(height: 2),
                    Text(
                      money(debt),
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFFC62828)),
                    ),
                  ] else ...[
                    const Text('QARZ',
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF2E7D32))),
                    const SizedBox(height: 2),
                    const Text("YO'Q",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF2E7D32))),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}