import 'package:flutter/material.dart';

/// Ekranlar yazılana kadar kullanılan geçici sayfa.
class PlaceholderPage extends StatelessWidget {
  const PlaceholderPage(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('$title — yakında', style: Theme.of(context).textTheme.titleMedium),
      ),
    );
  }
}
