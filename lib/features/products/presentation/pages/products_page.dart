import 'package:flutter/material.dart';

class ProductsPage extends StatelessWidget {
  final String? initialCategory;
  final String? initialQuery;

  const ProductsPage({super.key, this.initialCategory, this.initialQuery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: const Center(child: Text('Products Page')),
    );
  }
}
