import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/wardrobe_service.dart';
import '../../widgets/clothing_thumbnail.dart';
import '../../widgets/confirm_delete.dart';
import 'add_clothing_screen.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({super.key});

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final wardrobe = context.watch<WardrobeService>();
    final categories = ['All', 'Tops', 'Bottoms', 'Dresses', 'Shoes', 'Accessories'];
    final filtered = _filter == 'All'
        ? wardrobe.items
        : wardrobe.items.where((i) => i.category == _filter).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('My wardrobe')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const AddClothingScreen()),
        ),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, i) {
                final c = categories[i];
                return ChoiceChip(
                  label: Text(c),
                  selected: _filter == c,
                  onSelected: (_) => setState(() => _filter = c),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: filtered.isEmpty
                ? const Center(child: Text('No items in this category yet.'))
                : GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.72,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, i) {
                      final item = filtered[i];
                      final title = [item.color, item.subCategory]
                          .where((s) => s.trim().isNotEmpty)
                          .join(' ');
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Positioned.fill(
                                    child: ClothingThumbnail(item: item, borderRadius: 0),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => wardrobe.toggleFavoriteItem(item.id),
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          item.isFavorite ? Icons.favorite : Icons.favorite_border,
                                          size: 16,
                                          color: item.isFavorite
                                              ? Colors.red
                                              : Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    left: 8,
                                    child: GestureDetector(
                                      onTap: () async {
                                        final title = [item.color, item.subCategory].where((s) => s.trim().isNotEmpty).join(' ');
                                        final confirmed = await confirmDelete(
                                          context,
                                          title: 'Delete item?',
                                          message: 'This removes "${title.isEmpty ? item.subCategory : title}" from your wardrobe permanently.',
                                        );
                                        if (confirmed) wardrobe.deleteItem(item.id);
                                      },
                                      child: Container(
                                        width: 28,
                                        height: 28,
                                        decoration: const BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title.isEmpty ? item.subCategory : title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.category.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      letterSpacing: 0.4,
                                      color: Theme.of(context).colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
