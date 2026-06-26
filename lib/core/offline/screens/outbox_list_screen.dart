import 'package:flutter/material.dart';

class OutboxListScreen extends StatefulWidget {
  const OutboxListScreen({super.key});

  @override
  State<OutboxListScreen> createState() => _OutboxListScreenState();
}

class _OutboxListScreenState extends State<OutboxListScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Outbox'),
      ),
      body: const Center(
        child: Text('Offline sync outbox will appear here.'),
      ),
    );
  }
}
