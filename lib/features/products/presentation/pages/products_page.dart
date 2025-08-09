import 'package:flutter/material.dart';

class ProductsPage extends StatelessWidget {
  final String? initialCategory;
  final String? initialQuery;
  
  const ProductsPage({Key? key, this.initialCategory, this.initialQuery}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Products')),
      body: const Center(child: Text('Products Page')),
    );
  }
}
