import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/supabase.dart';
import 'chef_profile.dart';

/// Şef profili.
final chefProfileProvider =
    FutureProvider.autoDispose.family<ChefProfile?, String>((ref, chefId) async {
  final res = await supabase.rpc('get_chef_profile', params: {'p_chef_id': chefId});
  if (res == null) return null;
  return ChefProfile.fromMap(res as Map<String, dynamic>);
});

/// Şefin tüm yorumları.
final chefReviewsProvider =
    FutureProvider.autoDispose.family<List<ChefReview>, String>((ref, chefId) async {
  final rows = await supabase.rpc('get_chef_reviews', params: {'p_chef_id': chefId}) as List;
  return rows.map((r) => ChefReview.fromMap(r as Map<String, dynamic>)).toList();
});

/// Favoriye ekler / çıkarır (P4). Giriş yapılmamışsa false döner.
Future<bool> setFavorite({required String chefId, required bool favorite}) async {
  final userId = supabase.auth.currentUser?.id;
  if (userId == null) return false;
  if (favorite) {
    await supabase
        .from('favorites')
        .upsert({'customer_id': userId, 'chef_id': chefId}, ignoreDuplicates: true);
  } else {
    await supabase.from('favorites').delete().match({'customer_id': userId, 'chef_id': chefId});
  }
  return true;
}
