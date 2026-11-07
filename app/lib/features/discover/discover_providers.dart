import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase.dart';
import 'chef_summary.dart';
import 'discover_query.dart';

/// Kullanıcının o anki Keşfet sorgusu.
final discoverQueryProvider = StateProvider<DiscoverQuery>((ref) => const DiscoverQuery());

/// Verilen sorguya göre şefleri Supabase'den çeker.
final chefsProvider =
    FutureProvider.autoDispose.family<List<ChefSummary>, DiscoverQuery>((ref, query) async {
  final rows = await supabase.rpc('discover_chefs', params: query.toParams()) as List<dynamic>;
  return rows.map((r) => ChefSummary.fromMap(r as Map<String, dynamic>)).toList();
});
