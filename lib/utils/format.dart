const List<String> kMonthsUz = [
  'yanvar',
  'fevral',
  'mart',
  'aprel',
  'may',
  'iyun',
  'iyul',
  'avgust',
  'sentabr',
  'oktyabr',
  'noyabr',
  'dekabr',
];

/// Sonlarni 1 000 000 ko'rinishida bo'laklab beradi.
String fmt(int value) {
  final s = value.abs().toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    b.write(s[i]);
    final remaining = s.length - 1 - i;
    if (remaining > 0 && remaining % 3 == 0) b.write(' ');
  }
  return '${value < 0 ? '-' : ''}$b';
}

String money(int value) => '${fmt(value)} so\'m';

String hhmm(DateTime d) =>
    '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

String formatDate(DateTime d) =>
    '${d.day}-${kMonthsUz[d.month - 1]} ${d.year}';

String formatDateTime(DateTime d) => '${formatDate(d)} • ${hhmm(d)}';