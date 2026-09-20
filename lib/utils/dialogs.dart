import 'package:flutter/material.dart';

import 'sms.dart';

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