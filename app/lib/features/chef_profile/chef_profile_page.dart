import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'chef_profile.dart';
import 'chef_profile_providers.dart';
import 'widgets/menu_detail_sheet.dart';
import 'widgets/profile_sections.dart';

/// Şef profili (P1-P5).
class ChefProfilePage extends ConsumerStatefulWidget {
  const ChefProfilePage({super.key, required this.chefId});

  final String chefId;

  @override
  ConsumerState<ChefProfilePage> createState() => _ChefProfilePageState();
}

class _ChefProfilePageState extends ConsumerState<ChefProfilePage> {
  bool? _favorite; // ekrandaki anlık durum (sunucu yanıtını beklemeden)

  void _snack(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  Future<void> _toggleFavorite(ChefProfile chef) async {
    final next = !(_favorite ?? chef.isFavorite);
    setState(() => _favorite = next);
    try {
      final ok = await setFavorite(chefId: chef.id, favorite: next);
      if (!ok) {
        setState(() => _favorite = !next);
        _snack('Favorilere eklemek için giriş yapman gerekecek.');
      }
    } catch (_) {
      setState(() => _favorite = !next);
      _snack('Favori güncellenemedi, tekrar dene.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final result = ref.watch(chefProfileProvider(widget.chefId));

    return result.when(
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Profil yüklenemedi: $e')),
      ),
      data: (chef) {
        if (chef == null) {
          return Scaffold(appBar: AppBar(), body: const Center(child: Text('Şef bulunamadı.')));
        }
        final isFav = _favorite ?? chef.isFavorite;
        return Scaffold(
          body: RefreshIndicator(
            onRefresh: () async => ref.invalidate(chefProfileProvider(widget.chefId)),
            child: CustomScrollView(
              slivers: [
                ProfileAppBar(
                  chef: chef,
                  isFavorite: isFav,
                  onFavorite: () => _toggleFavorite(chef),
                ),
                SliverList.list(
                  children: [
                    ProfileHeader(chef: chef),
                    TrustSection(chef: chef),
                    const Divider(),
                    WorkStyleSection(chef: chef),
                    if ((chef.bio ?? '').trim().isNotEmpty) ...[
                      const Divider(),
                      AboutSection(bio: chef.bio!),
                    ],
                    if (chef.menus.isNotEmpty) ...[
                      const Divider(),
                      MenusSection(
                        menus: chef.menus,
                        onTap: (m) => showMenuDetailSheet(
                          context,
                          menu: m,
                          onOrder: () => _snack('Sipariş akışı yakında.'),
                        ),
                      ),
                    ],
                    if (chef.photos.isNotEmpty) ...[
                      const Divider(),
                      GallerySection(photos: chef.photos),
                    ],
                    const Divider(),
                    ReviewsSection(chef: chef),
                    const SizedBox(height: 24),
                  ],
                ),
              ],
            ),
          ),
          bottomNavigationBar: chef.acceptsCustom
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: FilledButton.icon(
                      icon: const Icon(Icons.edit_note),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Özel talep gönder'),
                      ),
                      onPressed: () => _snack('Özel talep akışı yakında.'),
                    ),
                  ),
                )
              : null,
        );
      },
    );
  }
}
