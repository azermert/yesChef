import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'env.dart';

SupabaseClient get supabase => Supabase.instance.client;

/// Router'ı oturum değişince yeniden değerlendirmek için.
class AuthChangeNotifier extends ChangeNotifier {
  AuthChangeNotifier() {
    if (Env.isConfigured) {
      _sub = supabase.auth.onAuthStateChange.listen((_) => notifyListeners());
    }
  }
  StreamSubscription<AuthState>? _sub;

  bool get isLoggedIn => Env.isConfigured && supabase.auth.currentSession != null;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final authNotifierProvider = Provider<AuthChangeNotifier>((ref) {
  final n = AuthChangeNotifier();
  ref.onDispose(n.dispose);
  return n;
});

class Profile {
  const Profile({required this.id, required this.fullName, required this.isChef, this.city});
  final String id;
  final String fullName;
  final bool isChef;
  final String? city;

  factory Profile.fromMap(Map<String, dynamic> m) => Profile(
        id: m['id'] as String,
        fullName: (m['full_name'] as String?) ?? '',
        isChef: (m['is_chef'] as bool?) ?? false,
        city: m['city'] as String?,
      );
}

/// Giriş yapmış kullanıcının profili.
final currentProfileProvider = FutureProvider<Profile?>((ref) async {
  ref.watch(authNotifierProvider);
  if (!Env.isConfigured) return null;
  final user = supabase.auth.currentUser;
  if (user == null) return null;
  final row = await supabase.from('profiles').select().eq('id', user.id).maybeSingle();
  return row == null ? null : Profile.fromMap(row);
});
