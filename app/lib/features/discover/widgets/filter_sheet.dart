import 'package:flutter/material.dart';

import '../../../core/constants.dart';
import '../discover_query.dart';

const _maxPrice = 2000.0;

/// Filtreler (K7). Uygulanan sorguyu döner.
Future<DiscoverQuery?> showFilterSheet(BuildContext context, DiscoverQuery query) {
  return showModalBottomSheet<DiscoverQuery>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _FilterSheet(initial: query),
  );
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initial});
  final DiscoverQuery initial;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late DiscoverQuery _q = widget.initial;
  late RangeValues _price = RangeValues(
    widget.initial.minPrice ?? 0,
    widget.initial.maxPrice ?? _maxPrice,
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.85,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  Text('Filtrele', style: theme.textTheme.titleLarge),
                  _Group<String>(
                    title: 'Mutfak türü',
                    options: cuisines,
                    selected: _q.cuisine,
                    label: (c) => c,
                    onChanged: (v) => setState(() => _q = _q.copyWith(cuisine: v)),
                  ),
                  _Group<ServiceFilter>(
                    title: 'Hizmet şekli',
                    options: ServiceFilter.values,
                    selected: _q.service,
                    label: (s) => s.label,
                    onChanged: (v) => setState(() => _q = _q.copyWith(service: v)),
                  ),
                  _Group<IngredientsFilter>(
                    title: 'Malzeme',
                    options: IngredientsFilter.values,
                    selected: _q.ingredients,
                    label: (s) => s.label,
                    onChanged: (v) => setState(() => _q = _q.copyWith(ingredients: v)),
                  ),
                  _Group<OrderModeFilter>(
                    title: 'Sipariş tipi',
                    options: OrderModeFilter.values,
                    selected: _q.orderMode,
                    label: (s) => s.label,
                    onChanged: (v) => setState(() => _q = _q.copyWith(orderMode: v)),
                  ),
                  const SizedBox(height: 16),
                  Text('Kişi başı fiyat', style: theme.textTheme.titleSmall),
                  RangeSlider(
                    values: _price,
                    max: _maxPrice,
                    divisions: 40,
                    labels: RangeLabels(
                      '₺${_price.start.round()}',
                      _price.end >= _maxPrice ? '₺${_maxPrice.round()}+' : '₺${_price.end.round()}',
                    ),
                    onChanged: (v) => setState(() => _price = v),
                  ),
                  Text(
                    '₺${_price.start.round()} – '
                    '${_price.end >= _maxPrice ? '₺${_maxPrice.round()}+' : '₺${_price.end.round()}'}',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, _q.clearFilters()),
                      child: const Text('Temizle'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.pop(
                        context,
                        _q.copyWith(
                          minPrice: _price.start > 0 ? _price.start : null,
                          maxPrice: _price.end < _maxPrice ? _price.end : null,
                        ),
                      ),
                      child: const Text('Uygula'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tek seçimli çip grubu; seçili çipe tekrar basınca seçim kalkar.
class _Group<T> extends StatelessWidget {
  const _Group({
    required this.title,
    required this.options,
    required this.selected,
    required this.label,
    required this.onChanged,
  });

  final String title;
  final List<T> options;
  final T? selected;
  final String Function(T) label;
  final ValueChanged<T?> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              for (final o in options)
                ChoiceChip(
                  label: Text(label(o)),
                  selected: o == selected,
                  onSelected: (_) => onChanged(o == selected ? null : o),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
