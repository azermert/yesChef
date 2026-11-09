import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../chef_profile.dart';
import '../chef_profile_providers.dart';
import 'menu_detail_sheet.dart';

const _pad = EdgeInsets.symmetric(horizontal: 16, vertical: 12);

class _Title extends StatelessWidget {
  const _Title(this.text, {this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          Expanded(child: Text(text, style: Theme.of(context).textTheme.titleMedium)),
          if (trailing != null) trailing!,
        ]),
      );
}

/// Kapak fotoğrafı ve favori kalbi (P1, P4).
class ProfileAppBar extends StatelessWidget {
  const ProfileAppBar({
    super.key,
    required this.chef,
    required this.isFavorite,
    required this.onFavorite,
  });

  final ChefProfile chef;
  final bool isFavorite;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return SliverAppBar(
      pinned: true,
      expandedHeight: 200,
      actions: [
        IconButton(
          tooltip: isFavorite ? 'Favorilerden çıkar' : 'Favorilere ekle',
          icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null),
          onPressed: onFavorite,
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: chef.avatarUrl != null
            ? Image.network(chef.avatarUrl!, fit: BoxFit.cover)
            : Container(
                color: scheme.primaryContainer,
                alignment: Alignment.center,
                child: Text(chef.initials,
                    style: Theme.of(context)
                        .textTheme
                        .displayMedium
                        ?.copyWith(color: scheme.onPrimaryContainer)),
              ),
      ),
    );
  }
}

/// Ad, ilçe, puan, "Yeni şef", mutfak türleri (P1).
class ProfileHeader extends StatelessWidget {
  const ProfileHeader({super.key, required this.chef});
  final ChefProfile chef;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: _pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(chef.fullName, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 4),
          Row(children: [
            const Icon(Icons.location_on_outlined, size: 16),
            const SizedBox(width: 4),
            Text([chef.district, chef.city].whereType<String>().join(', ')),
            const SizedBox(width: 12),
            if (chef.isNew || chef.ratingCount == 0)
              const Chip(label: Text('Yeni şef'), visualDensity: VisualDensity.compact)
            else ...[
              const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
              Text(' ${chef.ratingAvg.toStringAsFixed(1)} (${chef.ratingCount} yorum)'),
            ],
          ]),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final s in chef.specialties)
                Chip(label: Text(s), visualDensity: VisualDensity.compact),
            ],
          ),
        ],
      ),
    );
  }
}

/// Tamamlanma oranı; tıklanınca iptaller ve mazeretler (P1, Ö6).
class TrustSection extends StatelessWidget {
  const TrustSection({super.key, required this.chef});
  final ChefProfile chef;

  @override
  Widget build(BuildContext context) {
    if (chef.totalOrders == 0) {
      return const ListTile(
        leading: Icon(Icons.verified_outlined),
        title: Text('Henüz tamamlanmış siparişi yok'),
      );
    }
    final hasCancellations = chef.cancelledCount > 0;
    return ListTile(
      leading: const Icon(Icons.verified_outlined),
      title: Text('${chef.totalOrders} siparişin ${chef.completedCount} tanesi tamamlandı'),
      subtitle: hasCancellations ? Text('${chef.cancelledCount} iptal · detayları gör') : null,
      trailing: hasCancellations ? const Icon(Icons.chevron_right) : null,
      onTap: hasCancellations ? () => _showCancellations(context) : null,
    );
  }

  void _showCancellations(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.7),
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Text('İptaller', style: Theme.of(ctx).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (chef.cancellations.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('İptal detayı yok.'),
                ),
              for (final c in chef.cancellations)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.event_busy_outlined),
                  title: Text(formatDateTr(c.createdAt) +
                      (c.isNoShow ? ' · Gelmedi' : c.isLate ? ' · Son dakika' : '')),
                  subtitle: Text(c.excuse?.isNotEmpty == true
                      ? '“${c.excuse}”'
                      : 'Şef mazeret yazmadı.'),
                ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

/// Hizmet yeri, teslimat, malzeme, hizmet ilçeleri (P1).
class WorkStyleSection extends StatelessWidget {
  const WorkStyleSection({super.key, required this.chef});
  final ChefProfile chef;

  String get _ingredients => switch (chef.ingredientsPolicy) {
        'customer' => 'Malzemeyi sen alırsın, şef pişirir',
        'chef' => 'Malzemeyi şef alır',
        _ => 'Malzemeyi sen de alabilirsin, şef de',
      };

  @override
  Widget build(BuildContext context) {
    Widget row(IconData icon, String text) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Icon(icon, size: 20),
            const SizedBox(width: 12),
            Expanded(child: Text(text)),
          ]),
        );

    return Padding(
      padding: _pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Title('Çalışma şekli'),
          if (chef.comesToYou) row(Icons.home_outlined, 'Evine gelip pişirir'),
          if (chef.delivers)
            row(
              Icons.delivery_dining_outlined,
              chef.deliveryFee > 0
                  ? 'Kendi mutfağında pişirip getirir (teslimat ${formatPrice(chef.deliveryFee)})'
                  : 'Kendi mutfağında pişirip getirir (teslimat ücretsiz)',
            ),
          if (chef.pickup) row(Icons.storefront_outlined, 'Kendi mutfağında pişirir, sen gelip alırsın'),
          row(Icons.shopping_basket_outlined, _ingredients),
          if (chef.serviceDistricts.isNotEmpty)
            row(Icons.map_outlined, 'Hizmet bölgesi: ${chef.serviceDistricts.join(', ')}'),
        ],
      ),
    );
  }
}

class AboutSection extends StatelessWidget {
  const AboutSection({super.key, required this.bio});
  final String bio;

  @override
  Widget build(BuildContext context) => Padding(
        padding: _pad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [const _Title('Hakkımda'), Text(bio)],
        ),
      );
}

/// Menü kartları (P2).
class MenusSection extends StatelessWidget {
  const MenusSection({super.key, required this.menus, required this.onTap});
  final List<ChefMenu> menus;
  final ValueChanged<ChefMenu> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: _pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Title('Menüler'),
          for (final m in menus)
            Card(
              margin: const EdgeInsets.only(bottom: 8),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => onTap(m),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(child: Text(m.title, style: theme.textTheme.titleMedium)),
                        const Icon(Icons.chevron_right),
                      ]),
                      if (m.description != null) ...[
                        const SizedBox(height: 4),
                        Text(m.description!, style: theme.textTheme.bodyMedium),
                      ],
                      const SizedBox(height: 8),
                      MenuPrices(menu: m),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class GallerySection extends StatelessWidget {
  const GallerySection({super.key, required this.photos});
  final List<ChefPhoto> photos;

  @override
  Widget build(BuildContext context) => Padding(
        padding: _pad,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _Title('Galeri'),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(photos[i].url, width: 160, fit: BoxFit.cover),
                ),
              ),
            ),
          ],
        ),
      );
}

/// Son yorumlar ve "Tümünü gör" (P1).
class ReviewsSection extends StatelessWidget {
  const ReviewsSection({super.key, required this.chef});
  final ChefProfile chef;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: _pad,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Title(
            'Yorumlar',
            trailing: chef.reviews.length >= 5
                ? TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(
                      builder: (_) => _AllReviewsPage(chefId: chef.id, chefName: chef.fullName),
                    )),
                    child: const Text('Tümünü gör'),
                  )
                : null,
          ),
          if (chef.reviews.isEmpty) const Text('Henüz yorum yok.'),
          for (final r in chef.reviews) ReviewTile(review: r),
        ],
      ),
    );
  }
}

class ReviewTile extends StatelessWidget {
  const ReviewTile({super.key, required this.review});
  final ChefReview review;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            for (var i = 1; i <= 5; i++)
              Icon(i <= review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                  size: 16, color: Colors.amber),
            const SizedBox(width: 8),
            Expanded(
              child: Text('${review.customerName} · ${formatDateTr(review.createdAt)}',
                  style: theme.textTheme.bodySmall),
            ),
          ]),
          if (review.comment?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(review.comment!),
          ],
          if (review.chefReply?.isNotEmpty == true)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(8),
              width: double.infinity,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('Şefin cevabı: ${review.chefReply}', style: theme.textTheme.bodySmall),
            ),
        ],
      ),
    );
  }
}

class _AllReviewsPage extends ConsumerWidget {
  const _AllReviewsPage({required this.chefId, required this.chefName});
  final String chefId;
  final String chefName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(chefReviewsProvider(chefId));
    return Scaffold(
      appBar: AppBar(title: Text('$chefName · Yorumlar')),
      body: result.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Yorumlar yüklenemedi: $e')),
        data: (list) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: list.length,
          separatorBuilder: (_, __) => const Divider(),
          itemBuilder: (_, i) => ReviewTile(review: list[i]),
        ),
      ),
    );
  }
}
