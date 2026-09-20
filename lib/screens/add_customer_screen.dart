import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/models.dart';
import '../services/store.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key, required this.store});

  final AppStore store;

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _phone = TextEditingController();
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final customer = Customer(
      id: newId(),
      name: _name.text.trim(),
      phone: _phone.text.trim(),
    );
    await widget.store.addCustomer(customer);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YANGI MIJOZ')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(Icons.person_add_alt_1_rounded,
                size: 80, color: Color(0xFF106B66)),
            const SizedBox(height: 16),
            const Text(
              'Yangi mijoz qo\'shish',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 28),
            TextFormField(
              key: const Key('name-field'),
              controller: _name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: 'Ism *',
                labelStyle: const TextStyle(fontSize: 20),
                hintText: 'Masalan: Ali',
                hintStyle: const TextStyle(fontSize: 20, color: Color(0xFFB0BEC5)),
                prefixIcon: const Icon(Icons.person_rounded, size: 30),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ismni kiriting' : null,
            ),
            const SizedBox(height: 20),
            TextFormField(
              key: const Key('phone-field'),
              controller: _phone,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+()\s-]')),
                LengthLimitingTextInputFormatter(20),
              ],
              decoration: InputDecoration(
                labelText: 'Telefon raqami',
                labelStyle: const TextStyle(fontSize: 20),
                hintText: 'Masalan: +998 90 123 45 67',
                hintStyle: const TextStyle(fontSize: 20, color: Color(0xFFB0BEC5)),
                prefixIcon: const Icon(Icons.phone_rounded, size: 30),
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              'Telefon raqam majburiy emas.',
              style: TextStyle(
                  fontSize: 17,
                  color: Color(0xFF607D8B),
                  fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(68),
                backgroundColor: const Color(0xFF2E7D32),
                foregroundColor: Colors.white,
              ),
              onPressed: _saving ? null : _save,
              icon: const Icon(Icons.check_circle_rounded, size: 30),
              label: const Text('SAQLASH',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
            ),
          ],
        ),
      ),
    );
  }
}