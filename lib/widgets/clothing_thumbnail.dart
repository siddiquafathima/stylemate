import 'package:flutter/material.dart';
import '../models/clothing_item.dart';

/// Shows the clothing item's real photo when one exists. Otherwise
/// shows a category-specific fallback (an emoji, or one of the
/// hand-drawn accessory sketches for bags/watches) instead of a single
/// generic hanger icon for everything.
class ClothingThumbnail extends StatelessWidget {
  final ClothingItem item;
  final double borderRadius;

  const ClothingThumbnail({super.key, required this.item, this.borderRadius = 14});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    if (item.imageFile != null) {
      return ClipRRect(
        borderRadius: radius,
        child: Image.file(
          item.imageFile!,
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) => _fallback(context, radius),
        ),
      );
    }
    return _fallback(context, radius);
  }

  Widget _fallback(BuildContext context, BorderRadius radius) {
    final sub = item.subCategory.toLowerCase();

    // Special-cased sketch art for these two accessory types.
    String? sketchAsset;
    if (item.category == 'Accessories') {
      if (sub.contains('bag') || sub.contains('purse') || sub.contains('handbag')) {
        sketchAsset = 'assets/images/sketch_bag.png';
      } else if (sub.contains('watch')) {
        sketchAsset = 'assets/images/sketch_watch.png';
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
        borderRadius: radius,
      ),
      alignment: Alignment.center,
      padding: sketchAsset != null ? const EdgeInsets.all(10) : EdgeInsets.zero,
      child: sketchAsset != null
          ? Image.asset(sketchAsset, fit: BoxFit.contain)
          : Text(_emojiFor(item), style: const TextStyle(fontSize: 30)),
    );
  }

  /// Picks an icon from what the item actually is (its sub-category
  /// text, e.g. "Hoodie", "Jeans", "Sneakers"), falling back to its
  /// broad category. Emoji has no hoodie glyph, so hoodies, sweaters and
  /// jackets share the coat icon.
  String _emojiFor(ClothingItem item) {
    final text = item.subCategory.toLowerCase().trim();
    final words = text.split(RegExp(r'[^a-z]+')).where((w) => w.isNotEmpty).toList();
    // Matches whole words that START with any stem (so "sneakers" hits "sneaker").
    bool has(List<String> stems) => words.any((w) => stems.any((s) => w.startsWith(s)));
    // Short words that must match exactly (so "tiered" doesn't match "tie").
    bool exact(List<String> list) => words.any(list.contains);
    bool phrase(List<String> list) => list.any(text.contains);

    if (text.isNotEmpty) {
      // Footwear
      if (has(['sneaker', 'trainer'])) return '👟';
      if (has(['heel', 'stiletto', 'pump', 'wedge'])) return '👠';
      if (has(['boot'])) return '🥾';
      if (has(['sandal', 'slipper', 'flip', 'clog'])) return '🩴';
      if (has(['flat', 'ballet', 'loafer'])) return '🥿';
      if (has(['oxford', 'derby']) || phrase(['formal shoe'])) return '👞';
      if (has(['shoe'])) return '👟';

      // Accessories
      if (has(['watch'])) return '⌚';
      if (has(['sunglass'])) return '🕶️';
      if (has(['glass', 'spectacle'])) return '👓';
      if (has(['backpack'])) return '🎒';
      if (has(['bag', 'handbag', 'tote', 'clutch', 'purse'])) return '👜';
      if (has(['scarf', 'stole', 'dupatta', 'muffler'])) return '🧣';
      if (has(['glove'])) return '🧤';
      if (has(['beanie']) || exact(['cap'])) return '🧢';
      if (exact(['hat', 'hats'])) return '👒';
      if (has(['sock'])) return '🧦';
      if (exact(['tie']) || phrase(['bow tie'])) return '👔';
      if (has(['necklace', 'bracelet', 'earring', 'jewel']) || exact(['ring', 'rings'])) return '💍';

      // Outerwear (hoodie, sweatshirt, sweater, jackets, coats)
      if (has(['hoodie', 'hoody', 'sweatshirt', 'sweater', 'jumper', 'cardigan', 'pullover'])) return '🧥';
      if (has(['jacket', 'coat', 'blazer', 'shrug', 'parka', 'windcheater'])) return '🧥';

      // Bottoms
      if (has(['short'])) return '🩳';
      if (has(['jean', 'denim', 'trouser', 'pant', 'jogger', 'legging', 'palazzo', 'cargo', 'chino'])) return '👖';
      if (has(['skirt'])) return '👗';

      // Dresses & traditional wear
      if (has(['saree', 'sari'])) return '🥻';
      if (has(['kimono'])) return '👘';
      if (has(['swimsuit', 'bikini', 'swimwear'])) return '👙';
      if (has(['gown', 'dress', 'frock', 'sundress', 'jumpsuit', 'romper'])) return '👗';
      if (has(['kurti', 'kurta', 'tunic', 'salwar', 'lehenga', 'anarkali'])) return '👚';

      // Tops
      if (phrase(['formal shirt', 'dress shirt'])) return '👔';
      if (has(['blouse', 'crop', 'tank', 'camisole']) || exact(['top', 'tops'])) return '👚';
      if (has(['shirt', 'tee', 'polo', 't-shirt']) || exact(['t'])) return '👕';
    }

    // Fall back to the broad category
    switch (item.category) {
      case 'Tops':
        return '👕';
      case 'Bottoms':
        return '👖';
      case 'Dresses':
        return '👗';
      case 'Shoes':
        return '👟';
      case 'Outerwear':
        return '🧥';
      case 'Accessories':
        return '👜';
      default:
        return '🧷';
    }
  }
}
