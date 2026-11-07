/// Hizmet şekli filtresi (K7).
enum ServiceFilter {
  come('come', 'Evime gelsin'),
  deliver('deliver', 'Getirsin'),
  pickup('pickup', 'Gidip alayım');

  const ServiceFilter(this.value, this.label);
  final String value;
  final String label;
}

/// Malzeme filtresi (K7).
enum IngredientsFilter {
  customer('customer', 'Ben alırım'),
  chef('chef', 'Şef alsın');

  const IngredientsFilter(this.value, this.label);
  final String value;
  final String label;
}

/// Sipariş tipi filtresi (K7).
enum OrderModeFilter {
  menu('menu', 'Hazır menü'),
  custom('custom', 'Özel talep');

  const OrderModeFilter(this.value, this.label);
  final String value;
  final String label;
}

/// Sıralama (K8). `newest` sadece "Yeni katılanlar" bölümünde kullanılır.
enum DiscoverSort {
  recommended('recommended', 'Önerilen'),
  rating('rating', 'En yüksek puan'),
  nearest('nearest', 'En yakın'),
  price('price', 'En düşük fiyat'),
  newest('newest', 'En yeni');

  const DiscoverSort(this.value, this.label);
  final String value;
  final String label;

  static const userOptions = [recommended, rating, nearest, price];
}

const _unset = Object();

/// Keşfet sorgusu: konum, arama, filtreler ve sıralama.
class DiscoverQuery {
  const DiscoverQuery({
    this.city = 'Ankara',
    this.district,
    this.search = '',
    this.cuisine,
    this.service,
    this.ingredients,
    this.orderMode,
    this.minPrice,
    this.maxPrice,
    this.sort = DiscoverSort.recommended,
  });

  final String city;
  final String? district;
  final String search;
  final String? cuisine;
  final ServiceFilter? service;
  final IngredientsFilter? ingredients;
  final OrderModeFilter? orderMode;
  final double? minPrice;
  final double? maxPrice;
  final DiscoverSort sort;

  /// Filtre butonunda gösterilecek aktif filtre sayısı (mutfak türü kategori çipiyle de seçilebilir).
  int get activeFilterCount => [
        cuisine,
        service,
        ingredients,
        orderMode,
        (minPrice != null || maxPrice != null) ? true : null,
      ].where((e) => e != null).length;

  /// Arama veya filtre varsa bölümler yerine sonuç listesi gösterilir.
  bool get isSearching => search.trim().isNotEmpty || activeFilterCount > 0;

  DiscoverQuery copyWith({
    String? city,
    Object? district = _unset,
    String? search,
    Object? cuisine = _unset,
    Object? service = _unset,
    Object? ingredients = _unset,
    Object? orderMode = _unset,
    Object? minPrice = _unset,
    Object? maxPrice = _unset,
    DiscoverSort? sort,
  }) =>
      DiscoverQuery(
        city: city ?? this.city,
        district: identical(district, _unset) ? this.district : district as String?,
        search: search ?? this.search,
        cuisine: identical(cuisine, _unset) ? this.cuisine : cuisine as String?,
        service: identical(service, _unset) ? this.service : service as ServiceFilter?,
        ingredients:
            identical(ingredients, _unset) ? this.ingredients : ingredients as IngredientsFilter?,
        orderMode: identical(orderMode, _unset) ? this.orderMode : orderMode as OrderModeFilter?,
        minPrice: identical(minPrice, _unset) ? this.minPrice : minPrice as double?,
        maxPrice: identical(maxPrice, _unset) ? this.maxPrice : maxPrice as double?,
        sort: sort ?? this.sort,
      );

  /// Filtreleri temizler; konum ve arama kalır.
  DiscoverQuery clearFilters() => DiscoverQuery(city: city, district: district, search: search);

  Map<String, dynamic> toParams({int limit = 50}) => {
        'p_city': city,
        'p_district': district,
        'p_search': search.trim().isEmpty ? null : search.trim(),
        'p_cuisine': cuisine,
        'p_service': service?.value,
        'p_ingredients': ingredients?.value,
        'p_order_mode': orderMode?.value,
        'p_min_price': minPrice,
        'p_max_price': maxPrice,
        'p_sort': sort.value,
        'p_limit': limit,
      };

  @override
  bool operator ==(Object other) =>
      other is DiscoverQuery &&
      other.city == city &&
      other.district == district &&
      other.search == search &&
      other.cuisine == cuisine &&
      other.service == service &&
      other.ingredients == ingredients &&
      other.orderMode == orderMode &&
      other.minPrice == minPrice &&
      other.maxPrice == maxPrice &&
      other.sort == sort;

  @override
  int get hashCode => Object.hash(
      city, district, search, cuisine, service, ingredients, orderMode, minPrice, maxPrice, sort);
}
