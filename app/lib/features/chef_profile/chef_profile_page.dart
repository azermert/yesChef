import 'package:flutter/material.dart';

/// Şef profili. İçeriği henüz konuşulmadı; şimdilik yer tutucu (K6).
class ChefProfilePage extends StatelessWidget {
  const ChefProfilePage({super.key, required this.chefId});

  final String chefId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Şef profili')),
      body: const Center(child: Text('Şef profili yakında')),
    );
  }
}
