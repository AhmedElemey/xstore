import 'package:flutter/material.dart';

import '../../../../shared/widgets/xstore_text_field.dart';

class ListingFormField extends StatelessWidget {
  const ListingFormField({
    super.key,
    required this.label,
    this.controller,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });

  final String label;
  final TextEditingController? controller;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;

  @override
  Widget build(BuildContext context) {
    return XstoreTextField(
      controller: controller,
      label: label,
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
      maxLines: maxLines,
    );
  }
}
