import 'package:flutter/material.dart';

class OrderDetailsPage extends StatelessWidget {
  final String orderId;
  
  const OrderDetailsPage({Key? key, required this.orderId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Order Details')),
      body: Center(child: Text('Order ID: $orderId')),
    );
  }
}
