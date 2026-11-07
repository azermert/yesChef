import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../chef_summary.dart';

/// Şef kartı (K5): fotoğraf, ad, ilçe, puan, mutfak türleri, başlangıç fiyatı, çalışma şekli.
class ChefCard extends StatelessWidget {
  const ChefCard({super.key, required this.chef, this.width});

  final ChefSummary chef;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return SizedBox(
      width: width,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push('/sef/${chef.id}'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: chef.avatarUrl != null
                    ? Image.network(chef.avatarUrl!, fit: BoxFit.cover)
                    : Container(
                        color: scheme.primaryContainer,
                        alignment: Alignment.center,
                        child: Text(chef.initials,
                            style: theme.textTheme.headlineMedium
                                ?.copyWith(color: scheme.onPrimaryContainer)),
                      ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(chef.fullName,
                              style: theme.textTheme.titleMedium,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                        _Rating(chef: chef),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [chef.district, chef.city].whereType<String>().join(', '),
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      chef.specialties.join(' · '),
                      style: theme.textTheme.bodyMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chef.minPrice != null
                                ? 'Kişi başı ₺${chef.minPrice!.toStringAsFixed(0)}\'den'
                                : 'Özel teklif',
                            style: theme.textTheme.labelLarge?.copyWith(color: scheme.primary),
                          ),
                        ),
                        if (chef.comesToYou) const _ServiceIcon(Icons.home_outlined, 'Evine gelir'),
                        if (chef.delivers)
                          const _ServiceIcon(Icons.delivery_dining_outlined, 'Getirir'),
                        if (chef.pickup) const _ServiceIcon(Icons.storefront_outlined, 'Gel al'),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Rating extends StatelessWidget {
  const _Rating({required this.chef});
  final ChefSummary chef;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.labelMedium;
    if (chef.isNew || chef.ratingCount == 0) {
      return Chip(
        label: Text('Yeni şef', style: style),
        visualDensity: VisualDensity.compact,
        padding: EdgeInsets.zero,
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
        Text(' ${chef.ratingAvg.toStringAsFixed(1)} (${chef.ratingCount})', style: style),
      ],
    );
  }
}

class _ServiceIcon extends StatelessWidget {
  const _ServiceIcon(this.icon, this.tooltip);
  final IconData icon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Padding(
        padding: const EdgeInsets.only(left: 6),
        child: Icon(icon, size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
      ),
    );
  }
}
