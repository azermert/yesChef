import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/supabase.dart';

/// Giriş ve kayıt ekranı (e-posta + şifre).
class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isSignUp = false;
  bool _loading = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      if (_isSignUp) {
        final res = await supabase.auth.signUp(
          email: _email.text.trim(),
          password: _password.text,
          data: {'full_name': _name.text.trim()},
        );
        if (res.session == null && mounted) {
          _show('Kayıt alındı. E-postana gelen bağlantıyla hesabını doğrula.');
        }
      } else {
        await supabase.auth.signInWithPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
    } on AuthException catch (e) {
      _show(_translate(e.message));
    } catch (_) {
      _show('Bir hata oluştu, tekrar dene.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _translate(String msg) {
    final m = msg.toLowerCase();
    if (m.contains('invalid login')) return 'E-posta veya şifre hatalı.';
    if (m.contains('already registered')) return 'Bu e-posta zaten kayıtlı.';
    if (m.contains('email not confirmed')) return 'Önce e-postanı doğrula.';
    return msg;
  }

  void _show(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('yesChef',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        )),
                    const SizedBox(height: 8),
                    Text(_isSignUp ? 'Hesap oluştur' : 'Giriş yap',
                        textAlign: TextAlign.center, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 32),
                    if (_isSignUp) ...[
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(labelText: 'Ad Soyad', border: OutlineInputBorder()),
                        textCapitalization: TextCapitalization.words,
                        validator: (v) => (v == null || v.trim().length < 2) ? 'Adını gir' : null,
                      ),
                      const SizedBox(height: 16),
                    ],
                    TextFormField(
                      controller: _email,
                      decoration: const InputDecoration(labelText: 'E-posta', border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                      validator: (v) => (v == null || !v.contains('@')) ? 'Geçerli bir e-posta gir' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _password,
                      decoration: const InputDecoration(labelText: 'Şifre', border: OutlineInputBorder()),
                      obscureText: true,
                      validator: (v) => (v == null || v.length < 6) ? 'En az 6 karakter' : null,
                    ),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: _loading ? null : _submit,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: _loading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(_isSignUp ? 'Kayıt ol' : 'Giriş yap'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: _loading ? null : () => setState(() => _isSignUp = !_isSignUp),
                      child: Text(_isSignUp ? 'Zaten hesabın var mı? Giriş yap' : 'Hesabın yok mu? Kayıt ol'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
