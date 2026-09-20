import 'package:flutter/material.dart';

import 'screens/main_screen.dart';
import 'services/store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final store = AppStore();
  await store.load();
  runApp(TemirdaftarApp(store: store));
}

class TemirdaftarApp extends StatelessWidget {
  const TemirdaftarApp({super.key, required this.store});

  final AppStore store;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Savdo Daftari',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: MainScreen(store: store),
    );
  }

  ThemeData _buildTheme() {
    const primary = Color(0xFF106B66);
    final scheme =
        ColorScheme.fromSeed(seedColor: primary).copyWith(primary: primary);
    final base = ThemeData(useMaterial3: true, colorScheme: scheme);

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF4F7F6),
      appBarTheme: const AppBarTheme(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        toolbarHeight: 74,
        titleTextStyle: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w900,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size.fromHeight(60),
          textStyle: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: 0.8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(64, 56),
          textStyle: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700),
        ),
      ),
      cardTheme: const CardThemeData(
        elevation: 1.5,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(20))),
      ),
      inputDecorationTheme: InputDecorationThemeData(
        filled: true,
        fillColor: Colors.white,
        hintStyle:
            const TextStyle(fontSize: 20, color: Color(0xFFB0BEC5)),
        labelStyle:
            const TextStyle(fontSize: 20, color: Color(0xFF455A64)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        floatingLabelStyle: const TextStyle(fontSize: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCFD8DC), width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: primary, width: 2.4),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC62828), width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFC62828), width: 2.4),
        ),
      ),
    );
  }
}