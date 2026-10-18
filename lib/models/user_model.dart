class UserModel {
  final String id;
  final String name;
  final String email;
  String gender; // 'male' | 'female' | 'neutral' | 'unspecified' (not chosen yet)
  String themeKey;
  bool autoApplyAiTags;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.gender = 'unspecified',
    this.themeKey = 'neutral',
    this.autoApplyAiTags = false,
  });
}
