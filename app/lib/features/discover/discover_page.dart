import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants.dart';
import '../../core/env.dart';
import 'chef_summary.dart';
import 'discover_providers.dart';
import 'discover_query.dart';
import 'widgets/chef_card.dart';
import 'widgets/filter_sheet.dart';
import 'widgets/location_sheet.dart';

/// Keşfet (K1-K8): konum, arama, kategoriler; arama/filtre yoksa bölümler, varsa sonuç listesi.
class DiscoverPage extends ConsumerStatefulWidget {
  const DiscoverPage({super.key});

  @override
  ConsumerState<DiscoverPage> createState() => _DiscoverPageState();
}

class _DiscoverPageState extends ConsumerState<DiscoverPage> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _update(DiscoverQuery Function(DiscoverQuery) f) {
    final notifier = ref.read(discoverQueryProvider.notifier);
    notifier.state = f(notifier.state);
  }

  Future<void> _pickLocation(DiscoverQuery q) async {
    final res = await showLocationSheet(context, city: q.city, district: q.district);
    if (res != null) _update((q) => q.copyWith(city: res.$1, district: res.$2));
  }

  Future<void> _openFilters(DiscoverQuery q) async {
    final res = await showFilterSheet(context, q);
    if (res != null) _update((_) => res);
  }

  @override
  Widget build(BuildContext context) {
    final q = ref.watch(discoverQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: InkWell(
          onTap: () => _pickLocation(q),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_outlined, size: 20),
              const SizedBox(width: 4),
              Text(q.district != null ? '${q.district}, ${q.city}' : q.city),
              const Icon(Icons.expand_more),
            ],
          ),
        ),
      ),
      body: !Env.isConfigured
          ? const Center(child: Text('Supabase ayarları eksik (env.json).'))
          : RefreshIndicator(
              onRefresh: () async => ref.invalidate(chefsProvider),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(child: _searchBar(q)),
                  SliverToBoxAdapter(child: _categories(q)),
                  if (q.isSearching) ..._results(q) else ..._sections(q),
                  const SliverToBoxAdapter(child: SizedBox(height: 24)),
                ],
              ),
            ),
    );
  }

  Widget _searchBar(DiscoverQuery q) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchCtrl,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Şef veya yemek ara',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: q.search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchCtrl.clear();
                          _update((q) => q.copyWith(search: ''));
                        },
                      )
                    : null,
                border: const OutlineInputBorder(),
                isDense: true,
              ),
              onSubmitted: (v) => _update((q) => q.copyWith(search: v)),
            ),
          ),
          const SizedBox(width: 8),
          Badge(
            isLabelVisible: q.activeFilterCount > 0,
            label: Text('${q.activeFilterCount}'),
            child: IconButton.filledTonal(
              icon: const Icon(Icons.tune),
              tooltip: 'Filtrele',
              onPressed: () => _openFilters(q),
            ),
          ),
        ],
      ),
    );
  }

  Widget _categories(DiscoverQuery q) {
    return SizedBox(
      height: 48,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        children: [
          for (final c in cuisines)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: FilterChip(
                label: Text(c),
                selected: q.cuisine == c,
                onSelected: (_) => _update((q) => q.copyWith(cuisine: q.cuisine == c ? null : c)),
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _sections(DiscoverQuery q) {
    return [
      if (q.district != null)
        SliverToBoxAdapter(
          child: _Section(
            title: 'Yakınındaki şefler',
            query: q.copyWith(sort: DiscoverSort.nearest),
            where: (c) => c.isNear,
          ),
        ),
      SliverToBoxAdapter(
        child: _Section(title: 'En yüksek puanlılar', query: q.copyWith(sort: DiscoverSort.rating)),
      ),
      SliverToBoxAdapter(
        child: _Section(title: 'Yeni katılanlar', query: q.copyWith(sort: DiscoverSort.newest)),
      ),
    ];
  }

  List<Widget> _results(DiscoverQuery q) {
    final result = ref.watch(chefsProvider(q));
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  result.maybeWhen(data: (l) => '${l.length} şef bulundu', orElse: () => ''),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              DropdownButton<DiscoverSort>(
                value: DiscoverSort.userOptions.contains(q.sort) ? q.sort : DiscoverSort.recommended,
                underline: const SizedBox.shrink(),
                items: [
                  for (final s in DiscoverSort.userOptions)
                    DropdownMenuItem(value: s, child: Text(s.label)),
                ],
                onChanged: (s) => _update((q) => q.copyWith(sort: s)),
              ),
            ],
          ),
        ),
      ),
      ...result.when<List<Widget>>(
        loading: () => [
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
        ],
        error: (e, _) => [SliverToBoxAdapter(child: _ErrorBox(error: e))],
        data: (list) => list.isEmpty
            ? [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: Text('Aramana uygun şef bulunamadı.')),
                  ),
                ),
              ]
            : [
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  sliver: SliverList.builder(
                    itemCount: list.length,
                    itemBuilder: (_, i) => ChefCard(chef: list[i]),
                  ),
                ),
              ],
      ),
    ];
  }
}

/// Yatay kaydırılan şef bölümü (K4).
class _Section extends ConsumerWidget {
  const _Section({required this.title, required this.query, this.where});

  final String title;
  final DiscoverQuery query;
  final bool Function(ChefSummary)? where;

  static const _cardWidth = 260.0;
  static const _height = 300.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final result = ref.watch(chefsProvider(query));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        SizedBox(
          height: _height,
          child: result.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _ErrorBox(error: e),
            data: (all) {
              final list = where == null ? all : all.where(where!).toList();
              if (list.isEmpty) {
                return const Center(child: Text('Bu bölgede henüz şef yok.'));
              }
              return ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: list.length,
                itemBuilder: (_, i) => ChefCard(chef: list[i], width: _cardWidth),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ErrorBox extends StatelessWidget {
  const _ErrorBox({required this.error});
  final Object error;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text('Şefler yüklenemedi: $error',
          style: TextStyle(color: Theme.of(context).colorScheme.error)),
    );
  }
}
