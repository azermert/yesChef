import 'package:flutter/material.dart';

import '../../../core/constants.dart';

/// Şehir ve ilçe seçimi (K2). Seçilen değeri (şehir, ilçe) olarak döner.
Future<(String, String?)?> showLocationSheet(
  BuildContext context, {
  required String city,
  String? district,
}) {
  return showModalBottomSheet<(String, String?)>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _LocationSheet(city: city, district: district),
  );
}

class _LocationSheet extends StatefulWidget {
  const _LocationSheet({required this.city, this.district});
  final String city;
  final String? district;

  @override
  State<_LocationSheet> createState() => _LocationSheetState();
}

class _LocationSheetState extends State<_LocationSheet> {
  late String _city = widget.city;

  @override
  Widget build(BuildContext context) {
    final districts = districtsByCity[_city] ?? const <String>[];
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SegmentedButton<String>(
                segments: [for (final c in cities) ButtonSegment(value: c, label: Text(c))],
                selected: {_city},
                onSelectionChanged: (s) => setState(() => _city = s.first),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    title: const Text('Tüm ilçeler'),
                    trailing: _city == widget.city && widget.district == null
                        ? const Icon(Icons.check)
                        : null,
                    onTap: () => Navigator.pop(context, (_city, null)),
                  ),
                  for (final d in districts)
                    ListTile(
                      title: Text(d),
                      trailing: _city == widget.city && widget.district == d
                          ? const Icon(Icons.check)
                          : null,
                      onTap: () => Navigator.pop(context, (_city, d)),
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
