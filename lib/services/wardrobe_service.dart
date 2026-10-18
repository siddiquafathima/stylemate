import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/clothing_item.dart';
import '../models/outfit.dart';
import '../models/calendar_entry.dart';

/// Wardrobe store with LOCAL persistence via SharedPreferences, scoped
/// PER USER so different accounts on the same phone never see each
/// other's wardrobe.
///
/// To go live with Firebase later: replace the SharedPreferences reads
/// and writes below with Firestore collections under
/// `users/{uid}/clothingItems`, `users/{uid}/outfits`,
/// `users/{uid}/calendar` -- the public method signatures can stay the
/// same, so screens don't need to change.
class WardrobeService extends ChangeNotifier {
  final List<ClothingItem> items = [];
  final List<Outfit> outfits = [];
  final List<CalendarEntry> calendar = [];

  String? _userId;

  String get _itemsKey => 'stylemate_items_v2_${_userId ?? "guest"}';
  String get _outfitsKey => 'stylemate_outfits_v2_${_userId ?? "guest"}';
  String get _calendarKey => 'stylemate_calendar_v2_${_userId ?? "guest"}';

  /// Call this whenever the logged-in user changes -- after sign up,
  /// after log in, and after log out -- so each account gets its own
  /// separate wardrobe instead of sharing one global store.
  Future<void> setUserScope(String? userId) async {
    _userId = userId;
    items.clear();
    outfits.clear();
    calendar.clear();
    if (userId == null) {
      notifyListeners();
      return;
    }
    await loadFromStorage();
  }

  /// Restores this user's saved data. Starts genuinely empty for a
  /// brand new account -- no sample/seed items, so what you see is
  /// only what you've actually added.
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();

    final itemsJson = prefs.getString(_itemsKey);
    if (itemsJson != null) {
      final List<dynamic> list = jsonDecode(itemsJson);
      items
        ..clear()
        ..addAll(list.map((e) => ClothingItem.fromJson(e as Map<String, dynamic>)));
    }

    final outfitsJson = prefs.getString(_outfitsKey);
    if (outfitsJson != null) {
      final List<dynamic> list = jsonDecode(outfitsJson);
      outfits
        ..clear()
        ..addAll(list.map((e) => Outfit.fromJson(e as Map<String, dynamic>)));
    }

    final calendarJson = prefs.getString(_calendarKey);
    if (calendarJson != null) {
      final List<dynamic> list = jsonDecode(calendarJson);
      calendar
        ..clear()
        ..addAll(list.map((e) => CalendarEntry.fromJson(e as Map<String, dynamic>)));
    }

    notifyListeners();
  }

  Future<void> _persistItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_itemsKey, jsonEncode(items.map((i) => i.toJson()).toList()));
  }

  Future<void> _persistOutfits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_outfitsKey, jsonEncode(outfits.map((o) => o.toJson()).toList()));
  }

  Future<void> _persistCalendar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_calendarKey, jsonEncode(calendar.map((c) => c.toJson()).toList()));
  }

  void addItem(ClothingItem item) {
    items.add(item);
    _persistItems();
    notifyListeners();
  }

  void updateItem(String id, ClothingItem updated) {
    final index = items.indexWhere((i) => i.id == id);
    if (index != -1) {
      items[index] = updated;
      _persistItems();
      notifyListeners();
    }
  }

  void deleteItem(String id) {
    items.removeWhere((i) => i.id == id);
    // Clean this item out of every outfit that used it, so outfits
    // never end up pointing at clothes that no longer exist.
    for (final outfit in outfits) {
      outfit.itemIds.remove(id);
    }
    _persistItems();
    _persistOutfits();
    notifyListeners();
  }

  void toggleFavoriteItem(String id) {
    final item = items.firstWhere((i) => i.id == id);
    item.isFavorite = !item.isFavorite;
    _persistItems();
    notifyListeners();
  }

  void addOutfit(Outfit outfit) {
    outfits.add(outfit);
    _persistOutfits();
    notifyListeners();
  }

  void deleteOutfit(String id) {
    outfits.removeWhere((o) => o.id == id);
    // Also clear any calendar days that were pointing at this outfit,
    // so nothing references an outfit that no longer exists.
    calendar.removeWhere((e) => e.outfitId == id);
    _persistOutfits();
    _persistCalendar();
    notifyListeners();
  }

  void assignOutfitToDate(DateTime date, String outfitId) {
    calendar.removeWhere((e) => _isSameDay(e.date, date));
    calendar.add(CalendarEntry(date: date, outfitId: outfitId));
    final outfit = outfits.firstWhere((o) => o.id == outfitId);
    for (final itemId in outfit.itemIds) {
      final item = items.firstWhere((i) => i.id == itemId);
      item.wearCount += 1;
      item.lastWorn = date;
    }
    _persistCalendar();
    _persistItems();
    notifyListeners();
  }

  Outfit? outfitForDate(DateTime date) {
    try {
      final entry = calendar.firstWhere((e) => _isSameDay(e.date, date));
      return outfits.firstWhere((o) => o.id == entry.outfitId);
    } catch (_) {
      return null;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  List<ClothingItem> get mostWorn {
    final sorted = [...items]..sort((a, b) => b.wearCount.compareTo(a.wearCount));
    return sorted.take(5).toList();
  }

  List<ClothingItem> get forgottenItems {
    final now = DateTime.now();
    return items.where((i) {
      if (i.lastWorn == null) return true;
      return now.difference(i.lastWorn!).inDays > 30;
    }).toList();
  }
}
