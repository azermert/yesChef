import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_mode.dart';
import '../account/account_page.dart';
import '../placeholder_page.dart';

class _Tab {
  const _Tab(this.label, this.icon, this.page);
  final String label;
  final IconData icon;
  final Widget page;
}

const _customerTabs = [
  _Tab('Keşfet', Icons.search, PlaceholderPage('Keşfet')),
  _Tab('Siparişlerim', Icons.receipt_long, PlaceholderPage('Siparişlerim')),
  _Tab('Mesajlar', Icons.chat_bubble_outline, PlaceholderPage('Mesajlar')),
  _Tab('Hesabım', Icons.person_outline, AccountPage()),
];

const _chefTabs = [
  _Tab('Talepler', Icons.inbox_outlined, PlaceholderPage('Talepler')),
  _Tab('Takvim', Icons.calendar_month_outlined, PlaceholderPage('Takvim')),
  _Tab('Menülerim', Icons.restaurant_menu, PlaceholderPage('Menülerim')),
  _Tab('Mesajlar', Icons.chat_bubble_outline, PlaceholderPage('Mesajlar')),
  _Tab('Hesabım', Icons.person_outline, AccountPage()),
];

/// Moda göre (müşteri / şef) alt menüyü değiştiren ana iskelet.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final mode = ref.watch(appModeProvider);
    final tabs = mode == AppMode.customer ? _customerTabs : _chefTabs;

    ref.listen(appModeProvider, (_, __) => setState(() => _index = 0));

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [for (final t in tabs) t.page],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final t in tabs) NavigationDestination(icon: Icon(t.icon), label: t.label),
        ],
      ),
    );
  }
}
