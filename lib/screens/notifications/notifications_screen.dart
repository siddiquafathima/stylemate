import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/wardrobe_service.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wardrobe = context.watch<WardrobeService>();
    final notifications = NotificationService().generate(wardrobe);

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: notifications.isEmpty
          ? const Center(child: Text("You're all caught up!"))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, i) {
                final n = notifications[i];
                return Card(
                  child: ListTile(
                    leading: Icon(n.icon, color: Theme.of(context).colorScheme.primary),
                    title: Text(n.title, style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(n.message),
                  ),
                );
              },
            ),
    );
  }
}
