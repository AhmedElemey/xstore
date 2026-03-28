import 'package:flutter/material.dart';

/// Placeholder until seller profile is fully implemented.
class SellerProfileScreen extends StatelessWidget {
  const SellerProfileScreen({super.key, required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Seller')),
      body: Center(child: Text('Seller profile: $sellerId')),
    );
  }
}
