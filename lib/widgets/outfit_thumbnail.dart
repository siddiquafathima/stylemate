import 'package:flutter/material.dart';
import '../models/outfit.dart';
import '../services/wardrobe_service.dart';
import 'clothing_thumbnail.dart';

/// Shows a real photo from the outfit's items (checking every item, not
/// just the first, so a deleted item doesn't blank the preview). Falls
/// back to an emoji -- never the generic hanger icon -- if none of the
/// outfit's items exist anymore.
class OutfitThumbnail extends StatelessWidget {
  final Outfit outfit;
  final WardrobeService wardrobe;
  final double borderRadius;

  const OutfitThumbnail({super.key, required this.outfit, required this.wardrobe, this.borderRadius = 12});

  @override
  Widget build(BuildContext context) {
    for (final id in outfit.itemIds) {
      for (final item in wardrobe.items) {
        if (item.id == id) {
          return ClothingThumbnail(item: item, borderRadius: borderRadius);
        }
      }
    }
    final radius = BorderRadius.circular(borderRadius);
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary.withOpacity(0.3), borderRadius: radius),
      alignment: Alignment.center,
      child: const Text('👗', style: TextStyle(fontSize: 28)),
    );
  }
}
