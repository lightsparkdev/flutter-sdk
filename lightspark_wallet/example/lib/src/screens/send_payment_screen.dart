import 'package:flutter/material.dart';

class SendPaymentScreen extends StatefulWidget {
  const SendPaymentScreen({super.key});

  static Route route() {
    return MaterialPageRoute(
      builder: (context) => const SendPaymentScreen(),
      settings: const RouteSettings(name: 'send_payment'),
    );
  }

  @override
  SendPaymentScreenState createState() => SendPaymentScreenState();
}

class SendPaymentScreenState extends State<SendPaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send payment'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Send payment'),
          ],
        ),
      ),
    );
  }
}
