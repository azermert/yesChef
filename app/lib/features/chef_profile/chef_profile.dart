/// Şef profili verisi (get_chef_profile fonksiyonundan gelir).
class ChefProfile {
  const ChefProfile({
    required this.id,
    required this.fullName,
    required this.city,
    required this.serviceDistricts,
    required this.specialties,
    required this.serviceLocation,
    required this.orderMode,
    required this.delivery,
    required this.ingredientsPolicy,
    required this.deliveryFee,
    required this.ratingAvg,
    required this.ratingCount,
    required this.completedCount,
    required this.cancelledCount,
    required this.isFavorite,
    required this.menus,
    required this.photos,
    required this.reviews,
    required this.cancellations,
    this.avatarUrl,
    this.district,
    this.bio,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;
  final String city;
  final String? district;
  final List<String> serviceDistricts;
  final String? bio;
  final List<String> specialties;
  final String serviceLocation;
  final String orderMode;
  final String delivery;
  final String ingredientsPolicy;
  final double deliveryFee;
  final double ratingAvg;
  final int ratingCount;
  final int completedCount;
  final int cancelledCount;
  final bool isFavorite;
  final List<ChefMenu> menus;
  final List<ChefPhoto> photos;
  final List<ChefReview> reviews;
  final List<ChefCancellation> cancellations;

  int get totalOrders => completedCount + cancelledCount;
  bool get isNew => totalOrders < 3;

  bool get comesToYou => serviceLocation == 'customer_place' || serviceLocation == 'both';
  bool get _ownKitchen => serviceLocation == 'own_kitchen' || serviceLocation == 'both';
  bool get delivers => _ownKitchen && (delivery == 'chef_delivers' || delivery == 'both');
  bool get pickup => _ownKitchen && (delivery == 'customer_pickup' || delivery == 'both');
  bool get acceptsCustom => orderMode == 'custom' || orderMode == 'both';

  String get initials => fullName
      .trim()
      .split(RegExp(r'\s+'))
      .where((p) => p.isNotEmpty)
      .take(2)
      .map((p) => p[0])
      .join()
      .toUpperCase();

  ChefProfile withFavorite(bool value) => ChefProfile(
        id: id,
        fullName: fullName,
        avatarUrl: avatarUrl,
        city: city,
        district: district,
        serviceDistricts: serviceDistricts,
        bio: bio,
        specialties: specialties,
        serviceLocation: serviceLocation,
        orderMode: orderMode,
        delivery: delivery,
        ingredientsPolicy: ingredientsPolicy,
        deliveryFee: deliveryFee,
        ratingAvg: ratingAvg,
        ratingCount: ratingCount,
        completedCount: completedCount,
        cancelledCount: cancelledCount,
        isFavorite: value,
        menus: menus,
        photos: photos,
        reviews: reviews,
        cancellations: cancellations,
      );

  factory ChefProfile.fromMap(Map<String, dynamic> m) => ChefProfile(
        id: m['user_id'] as String,
        fullName: (m['full_name'] as String?) ?? '',
        avatarUrl: m['avatar_url'] as String?,
        city: (m['city'] as String?) ?? '',
        district: m['district'] as String?,
        serviceDistricts: _strings(m['service_districts']),
        bio: m['bio'] as String?,
        specialties: _strings(m['specialties']),
        serviceLocation: (m['service_location'] as String?) ?? 'both',
        orderMode: (m['order_mode'] as String?) ?? 'both',
        delivery: (m['delivery'] as String?) ?? 'both',
        ingredientsPolicy: (m['ingredients_policy'] as String?) ?? 'both',
        deliveryFee: _double(m['delivery_fee']) ?? 0,
        ratingAvg: _double(m['rating_avg']) ?? 0,
        ratingCount: _int(m['rating_count']),
        completedCount: _int(m['completed_count']),
        cancelledCount: _int(m['cancelled_count']),
        isFavorite: (m['is_favorite'] as bool?) ?? false,
        menus: _list(m['menus'], ChefMenu.fromMap),
        photos: _list(m['photos'], ChefPhoto.fromMap),
        reviews: _list(m['reviews'], ChefReview.fromMap),
        cancellations: _list(m['cancellations'], ChefCancellation.fromMap),
      );
}

class ChefMenu {
  const ChefMenu({
    required this.id,
    required this.title,
    required this.items,
    this.description,
    this.cuisine,
    this.priceWithIngredients,
    this.priceWithoutIngredients,
    this.minGuests,
    this.maxGuests,
  });

  final String id;
  final String title;
  final String? description;
  final String? cuisine;
  final double? priceWithIngredients;
  final double? priceWithoutIngredients;
  final int? minGuests;
  final int? maxGuests;
  final List<ChefMenuItem> items;

  factory ChefMenu.fromMap(Map<String, dynamic> m) => ChefMenu(
        id: m['id'] as String,
        title: (m['title'] as String?) ?? '',
        description: m['description'] as String?,
        cuisine: m['cuisine'] as String?,
        priceWithIngredients: _double(m['price_with_ingredients']),
        priceWithoutIngredients: _double(m['price_without_ingredients']),
        minGuests: (m['min_guests'] as num?)?.toInt(),
        maxGuests: (m['max_guests'] as num?)?.toInt(),
        items: _list(m['items'], ChefMenuItem.fromMap),
      );
}

class ChefMenuItem {
  const ChefMenuItem({required this.name, this.course, this.description});
  final String? course;
  final String name;
  final String? description;

  factory ChefMenuItem.fromMap(Map<String, dynamic> m) => ChefMenuItem(
        course: m['course'] as String?,
        name: (m['name'] as String?) ?? '',
        description: m['description'] as String?,
      );
}

class ChefPhoto {
  const ChefPhoto({required this.url, this.caption});
  final String url;
  final String? caption;

  factory ChefPhoto.fromMap(Map<String, dynamic> m) =>
      ChefPhoto(url: m['url'] as String, caption: m['caption'] as String?);
}

class ChefReview {
  const ChefReview({
    required this.rating,
    required this.customerName,
    required this.createdAt,
    this.comment,
    this.chefReply,
  });

  final int rating;
  final String customerName;
  final DateTime createdAt;
  final String? comment;
  final String? chefReply;

  factory ChefReview.fromMap(Map<String, dynamic> m) => ChefReview(
        rating: _int(m['rating']),
        customerName: (m['customer_name'] as String?) ?? 'Müşteri',
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
        comment: m['comment'] as String?,
        chefReply: m['chef_reply'] as String?,
      );
}

class ChefCancellation {
  const ChefCancellation({
    required this.createdAt,
    required this.isLate,
    required this.isNoShow,
    this.excuse,
  });

  final DateTime createdAt;
  final bool isLate;
  final bool isNoShow;
  final String? excuse;

  factory ChefCancellation.fromMap(Map<String, dynamic> m) => ChefCancellation(
        createdAt: DateTime.parse(m['created_at'] as String).toLocal(),
        isLate: (m['is_late'] as bool?) ?? false,
        isNoShow: (m['is_no_show'] as bool?) ?? false,
        excuse: m['excuse'] as String?,
      );
}

const _months = [
  'Ocak', 'Şubat', 'Mart', 'Nisan', 'Mayıs', 'Haziran',
  'Temmuz', 'Ağustos', 'Eylül', 'Ekim', 'Kasım', 'Aralık',
];

/// "7 Kasım 2026"
String formatDateTr(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

String formatPrice(double v) => '₺${v.toStringAsFixed(0)}';

List<String> _strings(Object? v) => ((v as List?) ?? const []).cast<String>();
double? _double(Object? v) => (v as num?)?.toDouble();
int _int(Object? v) => (v as num?)?.toInt() ?? 0;
List<T> _list<T>(Object? v, T Function(Map<String, dynamic>) f) =>
    ((v as List?) ?? const []).map((e) => f(e as Map<String, dynamic>)).toList();
