import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/app_mode.dart';
import '../../core/env.dart';
import '../../core/supabase.dart';

/// Hesabım: profil bilgisi, mod geçişi, çıkış. Hem müşteri hem şef modunda kullanılır.
class AccountPage extends ConsumerWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(currentProfileProvider);
    final mode = ref.watch(appModeProvider);
    final email = Env.isConfigured ? supabase.auth.currentUser?.email : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Hesabım')),
      body: profile.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Profil yüklenemedi: $e')),
        data: (p) {
          // Giriş yapılmamışsa (geliştirme aşaması) mod geçişi serbest.
          final canBeChef = p?.isChef ?? true;
          return ListView(
            children: [
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(p?.fullName.isNotEmpty == true ? p!.fullName : 'Misafir'),
                subtitle: email != null ? Text(email) : null,
              ),
              const Divider(),
              if (canBeChef)
                ListTile(
                  leading: Icon(mode == AppMode.chef ? Icons.person_outline : Icons.soup_kitchen_outlined),
                  title: Text(mode == AppMode.chef ? 'Müşteri moduna geç' : 'Şef moduna geç'),
                  onTap: () => ref.read(appModeProvider.notifier).state =
                      mode == AppMode.chef ? AppMode.customer : AppMode.chef,
                )
              else
                ListTile(
                  leading: const Icon(Icons.soup_kitchen_outlined),
                  title: const Text('Şef ol'),
                  subtitle: const Text('Yemeklerini yesChef\'te sun'),
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Şef başvurusu yakında.')),
                  ),
                ),
              if (email != null)
                ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('Çıkış yap'),
                  onTap: () async {
                    ref.read(appModeProvider.notifier).state = AppMode.customer;
                    await supabase.auth.signOut();
                  },
                ),
            ],
          );
        },
      ),
    );
  }
}
