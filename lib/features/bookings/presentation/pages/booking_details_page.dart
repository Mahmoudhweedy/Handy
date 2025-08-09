import 'package:flutter/material.dart';

class BookingDetailsPage extends StatelessWidget {
  final String bookingId;
  
  const BookingDetailsPage({Key? key, required this.bookingId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Booking Details')),
      body: Center(child: Text('Booking ID: $bookingId')),
    );
  }
}
