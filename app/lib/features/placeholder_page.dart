import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/app_mode.dart';

/// Ekranlar yazılana kadar kullanılan geçici sayfa.
class PlaceholderPage extends ConsumerWidget {
  const PlaceholderPage(this.title, {super.key, this.showModeSwitch = false});

  final String title;
  final bool showModeSwitch;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(appModeProvider);
    final isChef = mode == AppMode.chef;

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('$title — yakında', style: Theme.of(context).textTheme.titleMedium),
            if (showModeSwitch) ...[
              const SizedBox(height: 24),
              FilledButton.tonal(
                onPressed: () => ref.read(appModeProvider.notifier).state =
                    isChef ? AppMode.customer : AppMode.chef,
                child: Text(isChef ? 'Müşteri moduna geç' : 'Şef moduna geç'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
