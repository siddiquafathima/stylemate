import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../models/clothing_item.dart';
import '../../services/wardrobe_service.dart';
import '../../services/auth_service.dart';
import '../../services/ai_service.dart';

const _availableTags = ['Casual', 'Formal', 'Office', 'Party', 'College', 'Sporty', 'Outdoor'];

class AddClothingScreen extends StatefulWidget {
  const AddClothingScreen({super.key});

  @override
  State<AddClothingScreen> createState() => _AddClothingScreenState();
}

class _AddClothingScreenState extends State<AddClothingScreen> {
  File? _image;
  bool _loadingAi = false;
  Map<String, String>? _aiResult;

  final _categoryController = TextEditingController();
  final _subCategoryController = TextEditingController();
  final _colorController = TextEditingController();
  final _patternController = TextEditingController();
  final _seasonController = TextEditingController();
  final Set<String> _selectedTags = {};
  bool _autoApplyChecked = false;

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);
    if (picked == null) return;
    setState(() {
      _image = File(picked.path);
      _loadingAi = true;
    });

    final ai = context.read<AiService>();
    final result = await ai.classifyClothing(_image);
    if (!mounted) return;
    setState(() {
      _aiResult = result;
      _categoryController.text = result['category'] ?? '';
      _subCategoryController.text = result['subCategory'] ?? '';
      _colorController.text = result['color'] ?? '';
      _patternController.text = result['pattern'] ?? '';
      _seasonController.text = result['season'] ?? '';
      _loadingAi = false;
    });

    final auth = context.read<AuthService>();
    if (auth.currentUser?.autoApplyAiTags == true) {
      _save();
    }
  }

  void _save() {
    if (_categoryController.text.trim().isEmpty || _colorController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Category and Color are required -- fill these in before saving.')),
      );
      return;
    }
    final wardrobe = context.read<WardrobeService>();
    wardrobe.addItem(ClothingItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: _image?.path,
      category: _categoryController.text,
      subCategory: _subCategoryController.text,
      color: _colorController.text,
      pattern: _patternController.text,
      season: _seasonController.text,
      occasion: _selectedTags.isNotEmpty ? _selectedTags.first : 'Casual',
      tags: _selectedTags.map((t) => t.toLowerCase()).toList(),
    ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _subCategoryController.dispose();
    _colorController.dispose();
    _patternController.dispose();
    _seasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add clothing')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: _image == null
                      ? const Center(child: Icon(Icons.add_a_photo_outlined, size: 40))
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(_image!, fit: BoxFit.cover, width: double.infinity),
                        ),
                ),
              ),
              const SizedBox(height: 16),
              if (_loadingAi)
                const Row(
                  children: [
                    SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
                    SizedBox(width: 10),
                    Text('Reading the photo...'),
                  ],
                ),
              if (_aiResult != null && !_loadingAi) ...[
                TextField(controller: _categoryController, decoration: const InputDecoration(labelText: 'Category', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _subCategoryController, decoration: const InputDecoration(labelText: 'Sub-category', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _colorController, decoration: const InputDecoration(labelText: 'Color', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _patternController, decoration: const InputDecoration(labelText: 'Pattern', border: OutlineInputBorder())),
                const SizedBox(height: 12),
                TextField(controller: _seasonController, decoration: const InputDecoration(labelText: 'Season', border: OutlineInputBorder())),
                const SizedBox(height: 16),
                const Text('Tags', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                const Text('Pick what this item is for -- powers "What should I wear?" and Ask StyleMate.', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _availableTags.map((tag) {
                    final selected = _selectedTags.contains(tag);
                    return FilterChip(
                      label: Text(tag),
                      selected: selected,
                      onSelected: (value) => setState(() {
                        if (value) {
                          _selectedTags.add(tag);
                        } else {
                          _selectedTags.remove(tag);
                        }
                      }),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
                CheckboxListTile(
                  value: _autoApplyChecked,
                  contentPadding: EdgeInsets.zero,
                  title: const Text("Don't ask again -- auto-apply AI tags"),
                  onChanged: (value) {
                    setState(() => _autoApplyChecked = value ?? false);
                    context.read<AuthService>().setAutoApplyAiTags(value ?? false);
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(onPressed: _save, child: const Text('Save to wardrobe')),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
