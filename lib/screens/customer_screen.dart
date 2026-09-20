import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import '../services/store.dart';
import '../utils/dialogs.dart';
import '../utils/format.dart';
import '../utils/sms.dart';
import '../widgets/product_card.dart';

class CustomerScreen extends StatefulWidget {
  const CustomerScreen({super.key, required this.store, required this.customer});

  final AppStore store;
  final Customer customer;

  @override
  State<CustomerScreen> createState() => _CustomerScreenState();
}

class _CustomerScreenState extends State<CustomerScreen> {
  final Map<String, TextEditingController> _price = {};
  final Map<String, TextEditingController> _qty = {};
  bool _busy = false;

  AppStore get store => widget.store;
  Customer get customer => widget.customer;

  @override
  void initState() {
    super.initState();
    for (final p in kProducts) {
      _price[p.id] = TextEditingController();
      _qty[p.id] = TextEditingController();
    }
  }

  @override
  void dispose() {
    for (final c in _price.values) {
      c.dispose();
    }
    for (final c in _qty.values) {
      c.dispose();
    }
    super.dispose();
  }

  int _priceOf(Product p) => int.tryParse(_price[p.id]!.text) ?? 0;
  int _qtyOf(Product p) => int.tryParse(_qty[p.id]!.text) ?? 0;
  int _productTotal(Product p) => _priceOf(p) * _qtyOf(p);

  int get _grandTotal => kProducts.fold(0, (s, p) => s + _productTotal(p));

  List<SaleItem> _enteredItems() {
    return [
      for (final p in kProducts)
        if (_qtyOf(p) > 0 && _priceOf(p) > 0)
          SaleItem(
              productId: p.id,
              productName: p.name,
              price: _priceOf(p),
              quantity: _qtyOf(p)),
    ];
  }

  /// Xato bo'lsa xabar qaytaradi, aks holda null.
  String? _validate() {
    var anyEntered = false;
    for (final p in kProducts) {
      final price = _priceOf(p);
      final qty = _qtyOf(p);
      if (price > 0 || qty > 0) anyEntered = true;
      if (price > 0 && qty == 0) return '${p.name} uchun nechta ekanini kiriting';
      if (qty > 0 && price == 0) return '${p.name} uchun narxni kiriting';
    }
    if (!anyEntered) return 'Narx va nechta kiriting';
    if (_grandTotal == 0) return 'Narx va nechta kiriting';
    return null;
  }

  void _clear() {
    for (final c in _price.values) {
      c.clear();
    }
    for (final c in _qty.values) {
      c.clear();
    }
  }

  Future<void> _onToLandi() async {
    final err = _validate();
    if (err != null) {
      await showBigMessage(context, err);
      return;
    }
    final items = _enteredItems();
    final total = _grandTotal;
    final now = DateTime.now();
    final t = Transaction(
      id: newId(),
      customerId: customer.id,
      customerName: customer.name,
      date: now,
      items: items,
      amount: total,
      paid: total,
    );
    setState(() => _busy = true);
    await store.addTransaction(t);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _clear();
    });
    await showBigSuccess(
      context,
      title: 'SAVDO SAQLANDI',
      message: '${customer.name}\nJami: ${money(total)}\nTo\'lov: TO\'LANDI',
      smsPhone: customer.phone,
      smsBody: buildSmsText(
        customerName: customer.name,
        items: items,
        total: total,
        paid: total,
        date: now,
      ),
    );
  }

  Future<void> _onQarzgaOldi() async {
    final err = _validate();
    if (err != null) {
      await showBigMessage(context, err);
      return;
    }
    final total = _grandTotal;
    final oldDebt = store.customerDebt(customer.id);
    final given = await showDialog<int>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _DebtDialog(
        total: total,
        oldDebt: oldDebt,
      ),
    );
    if (given == null || !mounted) return;

    final items = _enteredItems();
    final now = DateTime.now();
    final t = Transaction(
      id: newId(),
      customerId: customer.id,
      customerName: customer.name,
      date: now,
      items: items,
      amount: total,
      paid: given,
    );
    setState(() => _busy = true);
    await store.addTransaction(t);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _clear();
    });
    final newDebt = oldDebt + total - given;
    await showBigSuccess(
      context,
      title: 'SAVDO SAQLANDI',
      message: 'Jami: ${money(total)}\n'
          'To\'landi: ${money(given)}\n'
          'Qarz: ${money(newDebt)}',
      smsPhone: customer.phone,
      smsBody: buildSmsText(
        customerName: customer.name,
        items: items,
        total: total,
        paid: given,
        date: now,
      ),
    );
  }

  Future<void> _clearDebt() async {
    final debt = store.customerDebt(customer.id);
    if (debt <= 0) return;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.payments_rounded,
            size: 54, color: Color(0xFF2E7D32)),
        title: const Text('QARZNI TO\'LASH', style: TextStyle(fontSize: 24)),
        content: Text(
          '${customer.name}\nTo\'liq qarz: ${money(debt)}\n\nMijoz qarzini to\'liq to\'ladi?',
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
              backgroundColor: const Color(0xFF2E7D32),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('HA', style: TextStyle(fontSize: 22)),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final t = Transaction(
      id: newId(),
      customerId: customer.id,
      customerName: customer.name,
      date: DateTime.now(),
      items: const [],
      amount: 0,
      paid: debt,
    );
    await store.addTransaction(t);
    if (!mounted) return;
    await showBigSuccess(
      context,
      title: 'QARZ TO\'LANDI',
      message: '${customer.name}\n${money(debt)} to\'landi.',
    );
  }

  @override
  Widget build(BuildContext context) {
    final debt = store.customerDebt(customer.id);
    return ListenableBuilder(
      listenable: store,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            title: Text(customer.name, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _header(debt),
                      const SizedBox(height: 14),
                      for (final p in kProducts) ...[
                        ProductCard(
                          product: p,
                          priceController: _price[p.id]!,
                          qtyController: _qty[p.id]!,
                          onChanged: () => setState(() {}),
                        ),
                        const SizedBox(height: 14),
                      ],
                      _summaryBlock(),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
              _bottomBar(debt),
            ],
          ),
        );
      },
    );
  }

  Widget _header(int debt) {
    final hasDebt = debt > 0;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE0E7E5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFF106B66).withValues(alpha: 0.12),
                child: const Icon(Icons.person_rounded,
                    size: 34, color: Color(0xFF106B66)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customer.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      customer.phone.isEmpty
                          ? 'Telefon yo\'q'
                          : customer.phone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 18,
                        color: customer.phone.isEmpty
                            ? const Color(0xFF90A4AE)
                            : const Color(0xFF37474F),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: hasDebt
                      ? Text('QARZ: ${money(debt)}',
                          style: const TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFFC62828)))
                      : const Text('QARZ YO\'Q',
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2E7D32))),
                ),
              ),
            ],
          ),
          if (hasDebt) ...[
            const SizedBox(height: 14),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(56),
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              onPressed: _busy ? null : _clearDebt,
              icon: const Icon(Icons.payments_rounded, size: 26),
              label: const Text('QARZNI TO\'LADI',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            ),
          ],
        ],
      ),
    );
  }

  Widget _summaryBlock() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F4F2),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF106B66), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'UMUMIY',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF106B66), letterSpacing: 2),
          ),
          const SizedBox(height: 12),
          for (final p in kProducts)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      p.name,
                      style: const TextStyle(
                          fontSize: 19, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Text(
                    money(_productTotal(p)),
                    style: const TextStyle(
                        fontSize: 19, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFF106B66), thickness: 1.6),
          ),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'JAMI:',
                  style: TextStyle(
                      fontSize: 26, fontWeight: FontWeight.w900, color: Color(0xFF0B3D3A)),
                ),
              ),
              Text(
                money(_grandTotal),
                style: const TextStyle(
                    fontSize: 30, fontWeight: FontWeight.w900, color: Color(0xFF0B3D3A)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _bottomBar(int debt) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(color: Color(0x22000000), blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(66),
                  backgroundColor: const Color(0xFF2E7D32),
                  foregroundColor: Colors.white,
                ),
                onPressed: _busy ? null : _onToLandi,
                icon: const Icon(Icons.check_circle_rounded, size: 30),
                label: const Text("TO'LANDI",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  minimumSize: const Size.fromHeight(66),
                  backgroundColor: const Color(0xFFC62828),
                  foregroundColor: Colors.white,
                ),
                onPressed: _busy ? null : _onQarzgaOldi,
                icon: const Icon(Icons.error_rounded, size: 30),
                label: const Text("QARZGA OLDI",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DebtDialog extends StatefulWidget {
  const _DebtDialog({
    required this.total,
    required this.oldDebt,
  });

  final int total;
  final int oldDebt;

  @override
  State<_DebtDialog> createState() => _DebtDialogState();
}

class _DebtDialogState extends State<_DebtDialog> {
  final TextEditingController _controller = TextEditingController();
  int _given = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int total = widget.total;
    final int newDebt = (widget.oldDebt + total - _given).clamp(0, 1 << 62);
    final bool invalid = _given > total;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      icon: const Icon(Icons.credit_card_rounded,
          size: 54, color: Color(0xFFC62828)),
      title: const Text(
        "MIJOZ QANCHA PUL BERDI?",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _infoRow('UMUMIY SUMMA', money(total)),
            if (widget.oldDebt > 0) ...[
              const SizedBox(height: 6),
              _infoRow('ESKI QARZ', money(widget.oldDebt), red: true),
            ],
            const SizedBox(height: 18),
            const Text(
              'BERILGAN PUL',
              style: TextStyle(
                  fontSize: 17, fontWeight: FontWeight.w700, color: Color(0xFF455A64)),
            ),
            const SizedBox(height: 6),
            TextField(
              key: const ValueKey('given-field'),
              controller: _controller,
              autofocus: true,
              keyboardType:
                  const TextInputType.numberWithOptions(signed: false),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
              onChanged: (v) =>
                  setState(() => _given = int.tryParse(v) ?? 0),
              decoration: InputDecoration(
                hintText: '0',
                suffixText: "so'm",
                suffixStyle: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF455A64)),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFFCFD8DC), width: 1.4),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFC62828), width: 2.4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFFBEAEA),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'QARZ: ${money(newDebt)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: newDebt == 0
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFC62828),
                ),
              ),
            ),
            if (invalid) ...[
              const SizedBox(height: 12),
              const Text(
                "Berilgan pul umumiy summadan katta bo'lishi mumkin emas",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18, color: Color(0xFFC62828)),
              ),
            ],
          ],
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: const Text('BEKOR', style: TextStyle(fontSize: 22)),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(150, 60),
            backgroundColor: const Color(0xFFC62828),
            foregroundColor: Colors.white,
          ),
          onPressed: invalid ? null : () => Navigator.of(context).pop(_given),
          child: const Text('SAQLASH',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
        ),
      ],
    );
  }

  Widget _infoRow(String label, String value, {bool red = false}) {
    final color = red ? const Color(0xFFC62828) : const Color(0xFF37474F);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 19, fontWeight: FontWeight.w700, color: color)),
        Text(value,
            style: TextStyle(
                fontSize: 20, fontWeight: FontWeight.w900, color: color)),
      ],
    );
  }
}