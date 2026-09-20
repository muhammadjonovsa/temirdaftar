import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BigNumberField extends StatelessWidget {
  const BigNumberField({
    super.key,
    required this.controller,
    this.suffix,
    this.hint = '0',
    this.onChanged,
  });

  final TextEditingController controller;
  final String? suffix;
  final String hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(signed: false),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(11),
      ],
      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        suffixText: suffix,
        suffixStyle: const TextStyle(
            fontSize: 19, fontWeight: FontWeight.w600, color: Color(0xFF455A64)),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCFD8DC), width: 1.4),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 2.4),
        ),
        hintStyle: const TextStyle(
            fontSize: 22, color: Color(0xFFB0BEC5), fontWeight: FontWeight.w400),
      ),
    );
  }
}