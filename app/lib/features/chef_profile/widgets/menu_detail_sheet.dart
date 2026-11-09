import 'package:flutter/material.dart';

import '../chef_profile.dart';

/// Menü detayı (P2): içerik, fiyatlar, "Sipariş ver".
Future<void> showMenuDetailSheet(
  BuildContext context, {
  required ChefMenu menu,
  required VoidCallback onOrder,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      // Kalemleri bölüme göre grupla (Çorba, Ana yemek, Tatlı...)
      final groups = <String, List<ChefMenuItem>>{};
      for (final i in menu.items) {
        groups.putIfAbsent(i.course ?? 'Menü', () => []).add(i);
      }
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Text(menu.title, style: theme.textTheme.headlineSmall),
                    if (menu.description != null) ...[
                      const SizedBox(height: 8),
                      Text(menu.description!, style: theme.textTheme.bodyMedium),
                    ],
                    for (final e in groups.entries) ...[
                      const SizedBox(height: 16),
                      Text(e.key, style: theme.textTheme.titleSmall),
                      for (final item in e.value)
                        ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.restaurant, size: 18),
                          title: Text(item.name),
                          subtitle: item.description != null ? Text(item.description!) : null,
                        ),
                    ],
                    const SizedBox(height: 16),
                    MenuPrices(menu: menu),
                    if (menu.minGuests != null || menu.maxGuests != null) ...[
                      const SizedBox(height: 8),
                      Text(_guestText(menu), style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      onOrder();
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text('Sipariş ver'),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

String _guestText(ChefMenu m) {
  if (m.minGuests != null && m.maxGuests != null) return '${m.minGuests}–${m.maxGuests} kişilik';
  if (m.maxGuests != null) return 'En fazla ${m.maxGuests} kişi';
  return 'En az ${m.minGuests} kişi';
}

/// Kişi başı malzemeli / malzemesiz fiyatlar.
class MenuPrices extends StatelessWidget {
  const MenuPrices({super.key, required this.menu});
  final ChefMenu menu;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    final strong = Theme.of(context)
        .textTheme
        .titleSmall
        ?.copyWith(color: Theme.of(context).colorScheme.primary);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (menu.priceWithIngredients != null)
          Row(children: [
            Expanded(child: Text('Malzemeyi şef alır', style: style)),
            Text('${formatPrice(menu.priceWithIngredients!)} / kişi', style: strong),
          ]),
        if (menu.priceWithoutIngredients != null)
          Row(children: [
            Expanded(child: Text('Malzemeyi sen alırsın', style: style)),
            Text('${formatPrice(menu.priceWithoutIngredients!)} / kişi', style: strong),
          ]),
      ],
    );
  }
}
