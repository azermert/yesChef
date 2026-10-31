import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Kullanıcının o an hangi modda olduğu. Şef rolü olan kullanıcı ikisi arasında geçebilir.
enum AppMode { customer, chef }

final appModeProvider = StateProvider<AppMode>((ref) => AppMode.customer);
