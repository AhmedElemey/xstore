import 'package:flutter/material.dart';

class XstoreTextField extends StatelessWidget {
  const XstoreTextField({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.obscure = false,
    this.keyboardType,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final TextInputAction? textInputAction;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      textInputAction: textInputAction,
      maxLines: obscure ? 1 : maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
      ),
    );
  }
}
