/// Keşfet kartında gösterilen şef bilgisi (discover_chefs fonksiyonundan gelir).
class ChefSummary {
  const ChefSummary({
    required this.id,
    required this.fullName,
    required this.city,
    required this.specialties,
    required this.ratingAvg,
    required this.ratingCount,
    required this.serviceLocation,
    required this.delivery,
    required this.isNear,
    required this.isNew,
    this.avatarUrl,
    this.district,
    this.minPrice,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;
  final String city;
  final String? district;
  final List<String> specialties;
  final double ratingAvg;
  final int ratingCount;
  final String serviceLocation; // own_kitchen | customer_place | both
  final String delivery; // chef_delivers | customer_pickup | both
  final double? minPrice;
  final bool isNear;
  final bool isNew;

  bool get comesToYou => serviceLocation == 'customer_place' || serviceLocation == 'both';
  bool get _cooksAtOwnKitchen => serviceLocation == 'own_kitchen' || serviceLocation == 'both';
  bool get delivers => _cooksAtOwnKitchen && (delivery == 'chef_delivers' || delivery == 'both');
  bool get pickup => _cooksAtOwnKitchen && (delivery == 'customer_pickup' || delivery == 'both');

  String get initials {
    final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    return parts.take(2).map((p) => p[0]).join().toUpperCase();
  }

  factory ChefSummary.fromMap(Map<String, dynamic> m) => ChefSummary(
        id: m['user_id'] as String,
        fullName: (m['full_name'] as String?) ?? '',
        avatarUrl: m['avatar_url'] as String?,
        city: (m['city'] as String?) ?? '',
        district: m['district'] as String?,
        specialties: ((m['specialties'] as List?) ?? const []).cast<String>(),
        ratingAvg: (m['rating_avg'] as num?)?.toDouble() ?? 0,
        ratingCount: (m['rating_count'] as num?)?.toInt() ?? 0,
        serviceLocation: (m['service_location'] as String?) ?? 'both',
        delivery: (m['delivery'] as String?) ?? 'both',
        minPrice: (m['min_price'] as num?)?.toDouble(),
        isNear: (m['is_near'] as bool?) ?? false,
        isNew: (m['is_new'] as bool?) ?? false,
      );
}
