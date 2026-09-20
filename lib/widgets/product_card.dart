import 'package:flutter/material.dart';

import '../models/models.dart';
import '../utils/format.dart';
import 'big_number_field.dart';

class ProductStyle {
  const ProductStyle({required this.background, required this.ink});

  final Color background;
  final Color ink;
}

ProductStyle productStyleOf(String id) {
  switch (id) {
    case 'meter':
      return const ProductStyle(
          background: Color(0xFFD9F1DE), ink: Color(0xFF1B5E20));
    case 'sixfive':
      return const ProductStyle(
          background: Color(0xFFDDEBFA), ink: Color(0xFF0D47A1));
    case 'shell':
      return const ProductStyle(
          background: Color(0xFFF9DEE7), ink: Color(0xFFAD1457));
    case 'thirty':
      return const ProductStyle(
          background: Color(0xFFFCF2CE), ink: Color(0xFF8A6D00));
    default:
      return const ProductStyle(
          background: Color(0xFFECEFF1), ink: Color(0xFF37474F));
  }
}

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    required this.priceController,
    required this.qtyController,
    this.onChanged,
  });

  final Product product;
  final TextEditingController priceController;
  final TextEditingController qtyController;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final style = productStyleOf(product.id);
    final price = int.tryParse(priceController.text) ?? 0;
    final qty = int.tryParse(qtyController.text) ?? 0;
    final total = price * qty;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: style.background,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: style.ink.withValues(alpha: 0.25), width: 1.6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: style.ink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  product.name.toUpperCase(),
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: style.ink,
                      letterSpacing: 0.5),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text('NARXI', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF455A64))),
          const SizedBox(height: 6),
          BigNumberField(
            key: ValueKey('price-${product.id}'),
            controller: priceController,
            suffix: 'so\'m',
            onChanged: (_) => onChanged?.call(),
          ),
          const SizedBox(height: 14),
          const Text('NECHTA', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF455A64))),
          const SizedBox(height: 6),
          BigNumberField(
            key: ValueKey('qty-${product.id}'),
            controller: qtyController,
            suffix: 'dona',
            onChanged: (_) => onChanged?.call(),
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'JAMI: ${money(total)}',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: style.ink),
            ),
          ),
        ],
      ),
    );
  }
}