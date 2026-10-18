import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/clothing_item.dart';

/// Result of an outfit suggestion: the AI's explanation text, plus the
/// specific wardrobe item ids it picked (so the UI can show real photos
/// of the recommended items, not just describe them in prose).
class OutfitSuggestion {
  final String explanation;
  final List<String> itemIds;
  OutfitSuggestion({required this.explanation, required this.itemIds});
}

/// Gemini-powered AI service.
///
/// The app does NOT hold a Gemini key. Every request goes to the small
/// StyleMate backend (backend/ folder, deployed on Railway), which adds
/// the key and picks the model on the server, then forwards the call to
/// Google. The backend URL and shared app token are set in
/// config/api_config.dart.
///
/// Every method below falls back to a safe, clearly-labeled default if
/// the network call fails (no internet, quota hit, server down, etc.) so
/// a flaky connection never crashes the app or your demo.
class AiService {
  bool get _configured =>
      aiBackendUrl.isNotEmpty &&
      !aiBackendUrl.contains('YOUR-APP') &&
      aiAppToken.isNotEmpty &&
      aiAppToken != 'PASTE_YOUR_APP_TOKEN_HERE';

  Uri _endpoint() => Uri.parse('${aiBackendUrl.replaceAll(RegExp(r"/+$"), "")}/generate');

  Map<String, String> _headers() => {
        'Content-Type': 'application/json',
        'x-app-token': aiAppToken,
      };

  Future<Map<String, String>> classifyClothing(File? imageFile) async {
    if (imageFile == null) return _blankClassification();
    if (!_configured) {
      debugPrint('[AiService] Backend URL / app token not set in lib/config/api_config.dart -- skipping AI tagging.');
      return _blankClassification();
    }

    try {
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      const prompt = '''
You are a clothing cataloging assistant. Look at this image of a single
clothing item and respond with ONLY a JSON object, no markdown fences,
no explanation, in exactly this shape:
{"category": "...", "subCategory": "...", "color": "...", "pattern": "...", "season": "..."}

Rules:
- category must be one of: Tops, Bottoms, Dresses, Shoes, Accessories, Outerwear
- season must be one of: Summer, Winter, All season, Monsoon
- color and pattern should be short, plain words (e.g. "Blue", "Solid", "Floral")
''';

      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt},
              {
                'inline_data': {
                  'mime_type': 'image/jpeg',
                  'data': base64Image,
                }
              }
            ]
          }
        ]
      });

      final response = await http
          .post(_endpoint(), headers: _headers(), body: body)
          .timeout(const Duration(seconds: 60));

      if (response.statusCode != 200) {
        debugPrint('[AiService] classifyClothing failed: HTTP ${response.statusCode} -- ${response.body}');
        return _blankClassification();
      }

      final decoded = jsonDecode(response.body);
      final text = decoded['candidates'][0]['content']['parts'][0]['text'] as String;
      final cleaned = text.replaceAll('```json', '').replaceAll('```', '').trim();
      final Map<String, dynamic> result = jsonDecode(cleaned);

      return result.map((key, value) => MapEntry(key, value.toString()));
    } catch (e) {
      // Network issue, quota exceeded, unexpected response shape, etc.
      // Return blanks rather than a guess, so the user just fills them
      // in manually instead of trusting a wrong auto-tag.
      debugPrint('[AiService] classifyClothing exception: $e');
      return _blankClassification();
    }
  }

  Map<String, String> _blankClassification() {
    return {
      'category': '',
      'subCategory': '',
      'color': '',
      'pattern': '',
      'season': 'All season',
    };
  }

  Future<OutfitSuggestion> suggestOutfit({
    required List<ClothingItem> wardrobe,
    required String occasion,
    required String weather,
    required String style,
  }) async {
    if (wardrobe.isEmpty) {
      return OutfitSuggestion(
        explanation: 'Add a few items to your wardrobe first, then I can suggest an outfit.',
        itemIds: [],
      );
    }
    // Include each item's id so the AI can tell us exactly which ones
    // it picked, letting the UI show their real photos.
    final wardrobeText = wardrobe
        .map((i) => '- id:${i.id} | ${i.color} ${i.subCategory} (${i.category}, ${i.occasion}, tags: ${i.tags.join(", ")})')
        .join('\n');

    final prompt = '''
You are a helpful personal stylist. Here is the user's wardrobe:
$wardrobeText

The user wants an outfit for: $occasion, in $weather weather, in a $style style.
Pick 2-4 items from the wardrobe above that work well together.

Respond with ONLY a single JSON object and nothing else -- no markdown
code fences, no text before or after it. Use exactly this shape:
{"explanation": "2-3 friendly sentences on why these work together", "itemIds": ["id1", "id2"]}

Rules:
- Every value in "itemIds" MUST be copied character-for-character from
  one of the "id:" values listed above.
- Never invent an id or recommend an item not listed above.
- Do not wrap the JSON in backticks or add any commentary outside it.
''';

    final raw = await _generateText(prompt);
    if (raw == null) {
      return OutfitSuggestion(explanation: _unreachableMessage(), itemIds: []);
    }
    final validIds = wardrobe.map((i) => i.id).toSet();
    String explanation = raw;
    List<String> ids = [];
    try {
      final cleaned = raw.replaceAll('```json', '').replaceAll('```', '').trim();
      final decoded = jsonDecode(cleaned) as Map<String, dynamic>;
      explanation = decoded['explanation'] as String? ?? raw;
      ids = (decoded['itemIds'] as List<dynamic>?)?.map((e) => e.toString()).where(validIds.contains).toList() ?? [];
    } catch (e) {
      debugPrint('[AiService] suggestOutfit JSON parse failed: $e -- raw: $raw');
    }
    // If the JSON didn't come through cleanly, or came through but with
    // no ids, fall back to matching the wardrobe against the actual
    // words in the explanation -- the AI describes items by color and
    // type in prose ("peach shirt"), not by their internal id, so
    // matching on description is far more reliable than searching for
    // the literal id string.
    if (ids.isEmpty) {
      ids = _matchItemsByDescription(explanation, wardrobe);
    }
    return OutfitSuggestion(explanation: explanation, itemIds: ids);
  }

  /// Finds wardrobe items whose color AND sub-category both appear as
  /// words in the given text (case-insensitive), so a plain-prose AI
  /// response can still be matched back to real photos.
  List<String> _matchItemsByDescription(String text, List<ClothingItem> wardrobe) {
    final lower = text.toLowerCase();
    final matches = <String>[];
    for (final item in wardrobe) {
      final color = item.color.toLowerCase().trim();
      final sub = item.subCategory.toLowerCase().trim();
      if (color.isEmpty || sub.isEmpty) continue;
      if (lower.contains(color) && lower.contains(sub)) {
        matches.add(item.id);
      }
    }
    return matches;
  }

  Future<String> askWardrobe({
    required List<ClothingItem> wardrobe,
    required String query,
  }) async {
    final wardrobeText = wardrobe.isEmpty
        ? '(wardrobe is empty)'
        : wardrobe
            .map((i) => '- ${i.color} ${i.subCategory} (${i.category}, pattern: ${i.pattern}, tags: ${i.tags.join(", ")})')
            .join('\n');

    final prompt = '''
You are a helpful wardrobe assistant helping the user decide whether to
buy something new. Here is the user's wardrobe:
$wardrobeText

The user asked: "$query"

If this is a "should I buy X" or "do I have X" style question:
- If they already own very similar items, say so plainly (name them),
  and then suggest a genuinely different color, fit, or style within
  that same category that they DON'T currently own -- something that
  would add real variety instead of duplicating what they have.
- If they don't own anything like it yet, say so, and if it's a
  versatile piece, note it could be a solid addition.
Only ever suggest colors/styles/items that make sense as real
clothing -- don't invent items unrelated to the question.
For any other kind of question, just answer directly and helpfully
based on the wardrobe above. Keep the whole answer to 2-4 sentences.
''';

    final result = await _generateText(prompt);
    return result ?? _unreachableMessage();
  }

  String _unreachableMessage() {
    if (!_configured) {
      return "AI isn't set up yet -- add your backend URL and token in lib/config/api_config.dart.";
    }
    return "Couldn't reach the AI just now -- check your internet connection and try again.";
  }

  Future<String?> _generateText(String prompt) async {
    if (!_configured) {
      debugPrint('[AiService] Backend URL / app token not set in lib/config/api_config.dart -- skipping AI call.');
      return null;
    }
    try {
      final body = jsonEncode({
        'contents': [
          {
            'parts': [
              {'text': prompt}
            ]
          }
        ]
      });
      final response = await http
          .post(_endpoint(), headers: _headers(), body: body)
          .timeout(const Duration(seconds: 60));
      if (response.statusCode != 200) {
        debugPrint('[AiService] _generateText failed: HTTP ${response.statusCode} -- ${response.body}');
        return null;
      }
      final decoded = jsonDecode(response.body);
      return (decoded['candidates'][0]['content']['parts'][0]['text'] as String).trim();
    } catch (e) {
      debugPrint('[AiService] _generateText exception: $e');
      return null;
    }
  }
}
