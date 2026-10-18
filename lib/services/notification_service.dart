import 'package:flutter/material.dart';
import 'wardrobe_service.dart';

class AppNotification {
  final String title;
  final String message;
  final IconData icon;
  AppNotification({required this.title, required this.message, required this.icon});
}

/// Generates real, data-driven notifications -- no fake or placeholder
/// alerts. Everything here is computed from the user's actual wardrobe
/// and calendar state at the moment the screen opens.
class NotificationService {
  List<AppNotification> generate(WardrobeService wardrobe) {
    final notifications = <AppNotification>[];

    if (wardrobe.items.isEmpty) {
      notifications.add(AppNotification(
        title: 'Empty wardrobe',
        message: 'Add your first item to start getting AI recommendations.',
        icon: Icons.add_a_photo_outlined,
      ));
      return notifications;
    }

    for (final item in wardrobe.forgottenItems.take(3)) {
      final message = item.lastWorn == null
          ? "You haven't worn your ${item.color} ${item.subCategory} yet."
          : "You haven't worn your ${item.color} ${item.subCategory} in ${DateTime.now().difference(item.lastWorn!).inDays} days.";
      notifications.add(AppNotification(title: 'Forgotten item', message: message, icon: Icons.visibility_off_outlined));
    }

    if (wardrobe.outfitForDate(DateTime.now()) == null) {
      notifications.add(AppNotification(
        title: 'No outfit planned',
        message: wardrobe.outfits.isEmpty
            ? "You haven't created any outfits yet -- try Create Outfit."
            : "You haven't planned an outfit for today yet.",
        icon: Icons.event_busy_outlined,
      ));
    }

    return notifications;
  }
}
