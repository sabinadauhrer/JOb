import 'package:flutter/material.dart';

class ApplicationHistoryScreen extends StatelessWidget {
  const ApplicationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bewerbungen')),
      body: const Center(child: Text('Bewerbungsverlauf folgt.')),
    );
  }
}
