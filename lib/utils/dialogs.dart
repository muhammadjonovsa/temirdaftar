import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'format.dart';
import 'sms.dart';

/// Mijozning eski qarzini qismen yoki to'liq to'lash uchun oyna.
/// To'langan summani qaytaradi, bekor qilinsa null.
Future<int?> showDebtPaymentDialog(
  BuildContext context, {
  required int debt,
}) {
  return showDialog<int>(
    context: context,
    barrierDismissible: false,
    builder: (_) => _DebtPaymentDialog(debt: debt),
  );
}

Future<void> showBigMessage(BuildContext context, String message) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      icon: const Icon(Icons.info_outline_rounded,
          size: 52, color: Color(0xFF106B66)),
      title: const Text('DIQQAT', style: TextStyle(fontSize: 26)),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 22, height: 1.4),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(56),
            backgroundColor: const Color(0xFF106B66),
          ),
          onPressed: () => Navigator.of(ctx).pop(),
          child: const Text('OK', style: TextStyle(fontSize: 22)),
        ),
      ],
    ),
  );
}

Future<void> showBigSuccess(
  BuildContext context, {
  required String title,
  required String message,
  String? smsPhone,
  String? smsBody,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) {
      final hasPhone = smsPhone != null && smsPhone.trim().isNotEmpty;
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        icon: const Icon(Icons.check_circle_rounded,
            size: 56, color: Color(0xFF2E7D32)),
        title: Text(title, style: const TextStyle(fontSize: 26)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, height: 1.4),
              ),
              if (smsBody != null) ...[
                const SizedBox(height: 24),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(64),
                    backgroundColor: const Color(0xFF229ED9),
                  ),
                  onPressed: () async {
                    try {
                      await sendTelegram(smsBody);
                    } catch (_) {
                      if (ctx.mounted) {
                        await showBigMessage(
                            ctx, 'Telegram ilovasi ochilmadi');
                      }
                    }
                  },
                  icon: const Icon(Icons.send_rounded, size: 30),
                  label: const Text('TELEGRAM',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 10),
                if (!hasPhone)
                  const Text(
                    'Telefon raqami kiritilmagan',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFC62828)),
                  )
                else
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(64),
                      backgroundColor: const Color(0xFF2E7D32),
                    ),
                    onPressed: () async {
                      try {
                        await sendSms(smsPhone, smsBody);
                      } catch (_) {
                        if (ctx.mounted) {
                          await showBigMessage(ctx, 'SMS ilovasi ochilmadi');
                        }
                      }
                    },
                    icon: const Icon(Icons.sms_rounded, size: 30),
                    label: const Text('SMS YUBORISH',
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.w800)),
                  ),
              ],
            ],
          ),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(56),
              backgroundColor: const Color(0xFF106B66),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(fontSize: 22)),
          ),
        ],
      );
    },
  );
}

class _DebtPaymentDialog extends StatefulWidget {
  const _DebtPaymentDialog({required this.debt});

  final int debt;

  @override
  State<_DebtPaymentDialog> createState() => _DebtPaymentDialogState();
}

class _DebtPaymentDialogState extends State<_DebtPaymentDialog> {
  final TextEditingController _controller = TextEditingController();
  int _paid = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int debt = widget.debt;
    final int newDebt = (debt - _paid).clamp(0, 1 << 62);
    final bool invalid = _paid > debt;
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      icon: const Icon(Icons.payments_rounded,
          size: 54, color: Color(0xFF2E7D32)),
      title: const Text(
        "MIJOZ QANCHA TO'LADI?",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 23, fontWeight: FontWeight.w900),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _infoRow('JAMI QARZ', money(debt), red: true),
            const SizedBox(height: 18),
            const Text(
              "TO'LANGAN PUL",
              style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF455A64)),
            ),
            const SizedBox(height: 6),
            TextField(
              key: const ValueKey('debt-payment-field'),
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
                  setState(() => _paid = int.tryParse(v) ?? 0),
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
                  borderSide:
                      const BorderSide(color: Color(0xFF2E7D32), width: 2.4),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFEAF6EC),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Text(
                'QOLGAN QARZ: ${money(newDebt)}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
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
                "To'langan pul qarzdan katta bo'lishi mumkin emas",
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
            backgroundColor: const Color(0xFF2E7D32),
            foregroundColor: Colors.white,
          ),
          onPressed: (_paid <= 0 || invalid)
              ? null
              : () => Navigator.of(context).pop(_paid),
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