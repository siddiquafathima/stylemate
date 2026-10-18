import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/outfit.dart';
import '../../services/wardrobe_service.dart';
import '../../widgets/clothing_thumbnail.dart';
import '../../widgets/outfit_thumbnail.dart';
import '../../widgets/confirm_delete.dart';

class CreateOutfitScreen extends StatefulWidget {
  const CreateOutfitScreen({super.key});

  @override
  State<CreateOutfitScreen> createState() => _CreateOutfitScreenState();
}

class _CreateOutfitScreenState extends State<CreateOutfitScreen> {
  final Set<String> _selectedIds = {};
  final _nameController = TextEditingController();

  void _save() {
    if (_selectedIds.isEmpty || _nameController.text.trim().isEmpty) return;
    context.read<WardrobeService>().addOutfit(Outfit(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: _nameController.text.trim(),
          itemIds: _selectedIds.toList(),
        ));
    setState(() {
      _selectedIds.clear();
      _nameController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Outfit saved')));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final wardrobe = context.watch<WardrobeService>();
    return Scaffold(
      appBar: AppBar(title: const Text('Create outfit')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Outfit name', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            const Text('Select items to combine'),
            const SizedBox(height: 8),
            Expanded(
              child: wardrobe.items.isEmpty
                  ? const Center(child: Text('Add some clothes first.'))
                  : GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                      ),
                      itemCount: wardrobe.items.length,
                      itemBuilder: (context, i) {
                        final item = wardrobe.items[i];
                        final selected = _selectedIds.contains(item.id);
                        return GestureDetector(
                          onTap: () => setState(
                            () => selected ? _selectedIds.remove(item.id) : _selectedIds.add(item.id),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: selected
                                  ? Border.all(color: Theme.of(context).colorScheme.primary, width: 3)
                                  : null,
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                ClothingThumbnail(item: item, borderRadius: 11),
                                if (selected)
                                  Container(
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.35),
                                    alignment: Alignment.topRight,
                                    padding: const EdgeInsets.all(6),
                                    child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(onPressed: _save, child: const Text('Save outfit')),
            ),
            if (wardrobe.outfits.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text('Your outfits', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              SizedBox(
                height: 110,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: wardrobe.outfits.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 10),
                  itemBuilder: (context, i) {
                    final outfit = wardrobe.outfits[i];
                    return SizedBox(
                      width: 90,
                      child: Stack(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 80,
                                width: 90,
                                child: OutfitThumbnail(outfit: outfit, wardrobe: wardrobe, borderRadius: 12),
                              ),
                              const SizedBox(height: 4),
                              Text(outfit.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                          Positioned(
                            top: 2,
                            right: 2,
                            child: GestureDetector(
                              onTap: () async {
                                final confirmed = await confirmDelete(
                                  context,
                                  title: 'Delete outfit?',
                                  message: 'This removes "${outfit.name}" and any calendar days it was assigned to.',
                                );
                                if (confirmed) wardrobe.deleteOutfit(outfit.id);
                              },
                              child: Container(
                                width: 22,
                                height: 22,
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.delete_outline, size: 14, color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
