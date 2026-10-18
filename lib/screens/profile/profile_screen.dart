import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/wardrobe_service.dart';
import '../../theme/theme_provider.dart';
import '../auth/auth_screen.dart';
import '../analytics/analytics_screen.dart';
import '../notifications/notifications_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final wardrobe = context.watch<WardrobeService>();
    final themeProvider = context.watch<ThemeProvider>();
    final user = auth.currentUser;
    final initial = (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : '?';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [themeProvider.palette.primary, themeProvider.palette.secondary]),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(initial, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(height: 12),
                Text(user?.name ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                Text(user?.email ?? '', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  children: [
                    _Badge(text: '${wardrobe.items.length} items styled'),
                    if (wardrobe.outfits.isNotEmpty) _Badge(text: '${wardrobe.outfits.length} outfits'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          _SectionHeader(icon: Icons.auto_awesome_outlined, title: 'AI preferences'),
          const SizedBox(height: 4),
          Card(
            child: SwitchListTile(
              title: const Text('Auto-apply AI tags'),
              subtitle: const Text('Skip the confirmation step after uploading a photo'),
              value: user?.autoApplyAiTags ?? false,
              onChanged: (v) => context.read<AuthService>().setAutoApplyAiTags(v),
            ),
          ),
          const SizedBox(height: 24),

          _SectionHeader(icon: Icons.bar_chart_outlined, title: 'Insights'),
          const SizedBox(height: 4),
          Card(
            child: ListTile(
              leading: const Icon(Icons.bar_chart),
              title: const Text('Wardrobe analytics'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AnalyticsScreen())),
            ),
          ),
          const SizedBox(height: 28),

          OutlinedButton(
            onPressed: () async {
              await context.read<AuthService>().logOut();
              if (!context.mounted) return;
              // Clear the wardrobe scope so the next person to log in
              // on this phone never sees this account's data.
              await context.read<WardrobeService>().setUserScope(null);
              if (!context.mounted) return;
              // Reset the theme back to neutral -- a logged-out screen
              // shouldn't still show the last account's chosen colors.
              context.read<ThemeProvider>().useNeutral();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const AuthScreen()),
                (route) => false,
              );
            },
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontSize: 11)),
    );
  }
}
