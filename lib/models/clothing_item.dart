import 'dart:io';

class ClothingItem {
  final String id;
  String? imagePath;
  String category;
  String subCategory;
  String color;
  String pattern;
  String season;
  String occasion;
  List<String> tags;
  DateTime? lastWorn;
  int wearCount;
  bool isFavorite;

  ClothingItem({
    required this.id,
    this.imagePath,
    required this.category,
    this.subCategory = '',
    this.color = '',
    this.pattern = '',
    this.season = 'All season',
    this.occasion = 'Casual',
    List<String>? tags,
    this.lastWorn,
    this.wearCount = 0,
    this.isFavorite = false,
  }) : tags = tags ?? [];

  /// The image as a File, for widgets that need to display it.
  /// Kept as a getter so the stored value (imagePath) stays simple
  /// text that's safe to save to disk.
  File? get imageFile => imagePath == null ? null : File(imagePath!);

  Map<String, dynamic> toJson() => {
        'id': id,
        'imagePath': imagePath,
        'category': category,
        'subCategory': subCategory,
        'color': color,
        'pattern': pattern,
        'season': season,
        'occasion': occasion,
        'tags': tags,
        'lastWorn': lastWorn?.toIso8601String(),
        'wearCount': wearCount,
        'isFavorite': isFavorite,
      };

  factory ClothingItem.fromJson(Map<String, dynamic> json) => ClothingItem(
        id: json['id'] as String,
        imagePath: json['imagePath'] as String?,
        category: json['category'] as String? ?? '',
        subCategory: json['subCategory'] as String? ?? '',
        color: json['color'] as String? ?? '',
        pattern: json['pattern'] as String? ?? '',
        season: json['season'] as String? ?? 'All season',
        occasion: json['occasion'] as String? ?? 'Casual',
        tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        lastWorn: json['lastWorn'] != null ? DateTime.parse(json['lastWorn'] as String) : null,
        wearCount: json['wearCount'] as int? ?? 0,
        isFavorite: json['isFavorite'] as bool? ?? false,
      );
}
