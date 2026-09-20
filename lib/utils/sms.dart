import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

import '../models/models.dart';
import 'format.dart';

String buildSmsText({
  required String customerName,
  required List<SaleItem> items,
  required int total,
  required int paid,
  required DateTime date,
}) {
  final b = StringBuffer();
  b.writeln('Assalomu alaykum, $customerName.');
  b.writeln('Sana: ${formatDate(date)}'); 
  if (items.isEmpty) {
    b.writeln('Qarz to\'lovi: ${money(paid)}');
    b.writeln('Rahmat!');
    return b.toString();
  }
  b.writeln('Bugungi xaridingiz:');
  for (final it in items.where((i) => i.quantity > 0)) {
    b.writeln(
        '${it.productName} — ${fmt(it.quantity)} dona × ${fmt(it.price)} so\'m = ${money(it.total)}');
  }
  b.writeln('Jami: ${money(total)}');
  if (paid >= total) {
    b.writeln('To\'lov: TO\'LANDI');
  } else if (paid <= 0) {
    b.writeln('Ushbu xarid QARZGA OLINDI.');
    b.writeln('Qarzingiz: ${money(total)}');
  } else {
    b.writeln('To\'landi: ${money(paid)}');
    b.writeln('Qarzingiz: ${money(total - paid)}');
  }
  b.write('Rahmat!');
  return b.toString();
}

Future<void> sendSms(String phone, String body) async {
  final p = phone.trim();
  final query = Uri.encodeComponent(body);
  final uriString =
      Platform.isAndroid ? 'sms:$p?body=$query' : 'sms:$p&body=$query';
  await launchUrl(Uri.parse(uriString),
      mode: LaunchMode.externalApplication);
}