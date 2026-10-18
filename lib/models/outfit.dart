class Outfit {
  final String id;
  String name;
  List<String> itemIds;
  List<String> tags;
  bool isFavorite;

  Outfit({
    required this.id,
    required this.name,
    List<String>? itemIds,
    List<String>? tags,
    this.isFavorite = false,
  })  : itemIds = itemIds ?? [],
        tags = tags ?? [];

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'itemIds': itemIds,
        'tags': tags,
        'isFavorite': isFavorite,
      };

  factory Outfit.fromJson(Map<String, dynamic> json) => Outfit(
        id: json['id'] as String,
        name: json['name'] as String,
        itemIds: (json['itemIds'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
        isFavorite: json['isFavorite'] as bool? ?? false,
      );
}
