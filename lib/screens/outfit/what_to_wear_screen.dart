import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/wardrobe_service.dart';
import '../../services/ai_service.dart';
import '../../models/clothing_item.dart';
import '../../widgets/clothing_thumbnail.dart';

class WhatToWearScreen extends StatefulWidget {
  const WhatToWearScreen({super.key});

  @override
  State<WhatToWearScreen> createState() => _WhatToWearScreenState();
}

class _WhatToWearScreenState extends State<WhatToWearScreen> {
  String _occasion = 'College';
  String _weather = 'Hot';
  String _style = 'Casual';
  OutfitSuggestion? _result;
  bool _loading = false;

  Future<void> _ask() async {
    setState(() => _loading = true);
    final wardrobe = context.read<WardrobeService>();
    final ai = context.read<AiService>();
    final result = await ai.suggestOutfit(
      wardrobe: wardrobe.items,
      occasion: _occasion,
      weather: _weather,
      style: _style,
    );
    if (!mounted) return;
    setState(() {
      _result = result;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const occasions = ['College', 'Office', 'Party', 'Casual outing'];
    const weathers = ['Sunny', 'Hot', 'Rainy', 'Cold', 'Mild'];
    const styles = ['Casual', 'Formal', 'Streetwear', 'Feminine'];
    final wardrobe = context.watch<WardrobeService>();

    return Scaffold(
      appBar: AppBar(title: const Text('What should I wear?')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _dropdown('Occasion', _occasion, occasions, (v) => setState(() => _occasion = v!)),
              const SizedBox(height: 12),
              _dropdown('Weather', _weather, weathers, (v) => setState(() => _weather = v!)),
              const SizedBox(height: 12),
              _dropdown('Style', _style, styles, (v) => setState(() => _style = v!)),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: _loading ? null : _ask, child: const Text('Show my outfit')),
              ),
              const SizedBox(height: 20),
              if (_loading) const Center(child: CircularProgressIndicator()),
              if (_result != null) ...[
                Card(child: Padding(padding: const EdgeInsets.all(16), child: Text(_result!.explanation))),
                if (_result!.itemIds.isNotEmpty) ...[
                  const SizedBox(height: 14),
                  const Text('Outfit board', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  const Text('Your recommended pieces, laid out together', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 14,
                      runSpacing: 14,
                      children: _sortedRecommendedItems(wardrobe).map((item) {
                        final title = [item.color, item.subCategory].where((s) => s.trim().isNotEmpty).join(' ');
                        return SizedBox(
                          width: 110,
                          child: Column(
                            children: [
                              SizedBox(height: 110, width: 110, child: ClothingThumbnail(item: item, borderRadius: 14)),
                              const SizedBox(height: 6),
                              Text(
                                title.isEmpty ? item.subCategory : title,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _dropdown(String label, String value, List<String> options, ValueChanged<String?> onChanged) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
      onChanged: onChanged,
    );
  }

  static const _categoryOrder = {
    'Outerwear': 0,
    'Tops': 1,
    'Dresses': 1,
    'Bottoms': 2,
    'Shoes': 3,
    'Accessories': 4,
  };

  /// Orders the recommended items the way you'd naturally lay them out
  /// flat on a bed -- outerwear/tops first, then bottoms, then shoes,
  /// then accessories -- instead of whatever order the AI happened to
  /// list them in.
  List<ClothingItem> _sortedRecommendedItems(WardrobeService wardrobe) {
    final items = <ClothingItem>[];
    for (final id in _result!.itemIds) {
      final match = wardrobe.items.where((it) => it.id == id);
      if (match.isNotEmpty) items.add(match.first);
    }
    items.sort((a, b) => (_categoryOrder[a.category] ?? 5).compareTo(_categoryOrder[b.category] ?? 5));
    return items;
  }
}
