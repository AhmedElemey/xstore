import 'package:flutter/material.dart';

/// Full reviews list — placeholder until wired to backend.
class ProductReviewsScreen extends StatelessWidget {
  const ProductReviewsScreen({super.key, required this.listingId});

  final String listingId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reviews')),
      body: Center(child: Text('All reviews for listing $listingId')),
    );
  }
}
