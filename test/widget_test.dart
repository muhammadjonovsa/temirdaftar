import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:temirdaftar/main.dart';
import 'package:temirdaftar/models/models.dart';
import 'package:temirdaftar/services/store.dart';

void main() {
  testWidgets('starts empty and adds a customer', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = AppStore();
    await store.load();

    await tester.pumpWidget(TemirdaftarApp(store: store));

    expect(find.text('MIJOZLAR'), findsOneWidget);
    expect(find.text("Mijozlar hali yo'q"), findsOneWidget);

    await tester.tap(find.byIcon(Icons.person_add_alt_1_rounded).first);
    await tester.pumpAndSettle();

    expect(find.text('YANGI MIJOZ'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('name-field')), 'Ali');
    await tester.enterText(
        find.byKey(const Key('phone-field')), '998901234567');
    await tester.tap(find.text('SAQLASH'));
    await tester.pumpAndSettle();

    expect(find.text('MIJOZLAR'), findsOneWidget);
    expect(find.text('Ali'), findsOneWidget);
    expect(find.text('QARZ'), findsOneWidget);
    expect(find.text("YO'Q"), findsOneWidget);
  });

  testWidgets('sale screen computes and saves a paid sale', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = AppStore();
    await store.load();
    await store.addCustomer(const Customer(
        id: 'c1', name: 'Ali', phone: '998901234567'));
    await tester.pumpWidget(TemirdaftarApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ali'));
    await tester.pumpAndSettle();

    expect(find.text('1 METRLI'), findsOneWidget);
    expect(find.text('6.5 LI'), findsOneWidget);

    await tester.enterText(
        find.byKey(const ValueKey('price-meter')), '20000');
    await tester.enterText(find.byKey(const ValueKey('qty-meter')), '5');
    await tester.pump();

    expect(find.text('JAMI: 100 000 so\'m'), findsOneWidget);
    expect(find.text('100 000 so\'m'), findsWidgets);

    await tester.tap(find.text("TO'LANDI"));
    await tester.pumpAndSettle();

    expect(find.text('SAVDO SAQLANDI'), findsOneWidget);
    expect(find.text('SMS YUBORISH'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('SAVDO SAQLANDI'), findsNothing);
  });

  testWidgets('sale blocked when nothing is entered', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = AppStore();
    await store.load();
    await store.addCustomer(
        const Customer(id: 'c1', name: 'Ali', phone: ''));
    await tester.pumpWidget(TemirdaftarApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ali'));
    await tester.pumpAndSettle();

    await tester.tap(find.text("TO'LANDI"));
    await tester.pumpAndSettle();

    expect(find.text('Narx va nechta kiriting'), findsOneWidget);
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  });

  testWidgets('qarzga oldi saves credit, computes debt and offers SMS',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = AppStore();
    await store.load();
    await store.addCustomer(
        const Customer(id: 'c1', name: 'Ali', phone: '998901234567'));
    await tester.pumpWidget(TemirdaftarApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ali'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('price-meter')), '20000');
    await tester.enterText(find.byKey(const ValueKey('qty-meter')), '5');
    await tester.pump();

    await tester.tap(find.text('QARZGA OLDI'));
    await tester.pumpAndSettle();

    expect(find.text('MIJOZ QANCHA PUL BERDI?'), findsOneWidget);

    await tester.enterText(
        find.byKey(const ValueKey('given-field')), '30000');
    await tester.pumpAndSettle();

    expect(find.text('QARZ: 70 000 so\'m'), findsOneWidget);

    await tester.tap(find.text('SAQLASH'));
    await tester.pumpAndSettle();

    expect(find.text('SAVDO SAQLANDI'), findsOneWidget);
    expect(find.textContaining('Qarz: 70 000 so\'m'), findsOneWidget);
    expect(find.text('SMS YUBORISH'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('QARZ: 70 000 so\'m'), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();

    expect(find.text('QARZ:'), findsOneWidget);
    expect(find.text('70 000 so\'m'), findsOneWidget);
  });

  testWidgets('qarzga oldi with no money given becomes full credit',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final store = AppStore();
    await store.load();
    await store.addCustomer(
        const Customer(id: 'c1', name: 'Ali', phone: '998901234567'));
    await tester.pumpWidget(TemirdaftarApp(store: store));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Ali'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const ValueKey('price-meter')), '20000');
    await tester.enterText(find.byKey(const ValueKey('qty-meter')), '5');
    await tester.pump();

    await tester.tap(find.text('QARZGA OLDI'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('SAQLASH'));
    await tester.pumpAndSettle();

    expect(find.text('SAVDO SAQLANDI'), findsOneWidget);
    expect(find.textContaining('Qarz: 100 000 so\'m'), findsOneWidget);
    expect(find.text('SMS YUBORISH'), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();
  });
}