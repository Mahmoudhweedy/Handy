import 'package:flutter/material.dart';

class ProductDetailsPage extends StatelessWidget {
  final String productId;
  
  const ProductDetailsPage({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Product Details')),
      body: Center(child: Text('Product ID: $productId')),
    );
  }
}
