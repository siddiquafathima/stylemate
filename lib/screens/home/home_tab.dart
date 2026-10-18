import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/wardrobe_service.dart';
import '../../services/weather_service.dart';
import '../../widgets/clothing_thumbnail.dart';
import '../outfit/what_to_wear_screen.dart';
import '../wardrobe/add_clothing_screen.dart';
import '../wardrobe/ask_wardrobe_screen.dart';
import '../notifications/notifications_screen.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  WeatherInfo? _weather;
  bool _loadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    final weather = await WeatherService().fetchCurrentWeather();
    if (!mounted) return;
    setState(() {
      _weather = weather;
      _loadingWeather = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthService>();
    final wardrobe = context.watch<WardrobeService>();
    final theme = Theme.of(context);
    final palette = context.watch<ThemeProvider>().palette;
    final iconStyle = palette.iconStyle;
    final name = auth.currentUser?.name ?? 'there';
    final todaysOutfit = wardrobe.outfitForDate(DateTime.now());

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(palette.radius + 4),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${_greeting()}, $name',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                        ),
                      ),
                      IconButton(
                        icon: Icon(AppIcons.bell(iconStyle), color: Colors.white),
                        onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text('Ready for a stylish day?', style: TextStyle(color: Colors.white70, fontSize: 13)),
                  const SizedBox(height: 16),
                  if (_loadingWeather)
                    const Row(
                      children: [
                        SizedBox(width: 14, height: 14, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)),
                        SizedBox(width: 8),
                        Text('Checking the weather...', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ],
                    )
                  else if (_weather != null)
                    Row(
                      children: [
                        Icon(_weatherIcon(_weather!.condition), color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${_weather!.tempC.round()}°C, ${_weather!.condition}${_weather!.cityName.isNotEmpty ? ' in ${_weather!.cityName}' : ''}',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500),
                          ),
                        ),
                        GestureDetector(
                          onTap: _changeLocation,
                          child: const Icon(Icons.edit_location_alt_outlined, color: Colors.white70, size: 16),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        const Expanded(
                          child: Text("Couldn't fetch live weather -- pick it manually below.", style: TextStyle(color: Colors.white70, fontSize: 12)),
                        ),
                        TextButton(
                          onPressed: _changeLocation,
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                          child: const Text('Set city', style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline)),
                        ),
                        const SizedBox(width: 8),
                        TextButton(
                          onPressed: () {
                            setState(() => _loadingWeather = true);
                            _loadWeather();
                          },
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(50, 30)),
                          child: const Text('Retry', style: TextStyle(color: Colors.white, fontSize: 12, decoration: TextDecoration.underline)),
                        ),
                      ],
                    ),
                  const SizedBox(height: 14),
                  if (todaysOutfit != null)
                    Text('Today: ${todaysOutfit.name}', style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w500))
                  else
                    const Text("No outfit logged for today yet.", style: TextStyle(color: Colors.white70, fontSize: 13)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Theme-derived quick actions -- three tonal variants of the
            // active theme's primary color, so these actually change
            // when the user picks a different theme, not fixed colors.
            Row(
              children: [
                Expanded(
                  child: _QuickAction(
                    icon: AppIcons.addPhoto(iconStyle),
                    label: 'Add\nclothing',
                    colors: [theme.colorScheme.primary, Color.lerp(theme.colorScheme.primary, Colors.black, 0.15)!],
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AddClothingScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: AppIcons.help(iconStyle),
                    label: 'What should\nI wear?',
                    colors: [theme.colorScheme.primary, Color.lerp(theme.colorScheme.primary, Colors.white, 0.25)!],
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const WhatToWearScreen())),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickAction(
                    icon: AppIcons.search(iconStyle),
                    label: 'Ask\nStyleMate',
                    colors: [Color.lerp(theme.colorScheme.primary, Colors.orange, 0.3)!, theme.colorScheme.primary],
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AskWardrobeScreen())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Recently added', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                Text('${wardrobe.items.length} items', style: TextStyle(color: theme.colorScheme.primary, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 110,
              child: wardrobe.items.isEmpty
                  ? const Text('Add your first item to see it here.')
                  : ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: wardrobe.items.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (context, i) {
                        final item = wardrobe.items[wardrobe.items.length - 1 - i];
                        return SizedBox(
                          width: 90,
                          child: Column(
                            children: [
                              Expanded(child: ClothingThumbnail(item: item)),
                              const SizedBox(height: 4),
                              Text(item.subCategory, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11)),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changeLocation() async {
    final weatherService = WeatherService();
    final currentCity = await weatherService.getManualCity();
    final controller = TextEditingController(text: currentCity ?? '');
    if (!mounted) return;

    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set your city'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Auto-detecting your city from your network isn\'t always accurate. Set it manually for correct weather.', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'e.g. Bengaluru', border: OutlineInputBorder()),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          if (currentCity != null)
            TextButton(
              onPressed: () => Navigator.of(context).pop(''),
              child: const Text('Use auto-detect instead'),
            ),
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(controller.text), child: const Text('Save')),
        ],
      ),
    );

    if (result == null) return; // cancelled
    await weatherService.setManualCity(result.isEmpty ? null : result);
    if (!mounted) return;
    setState(() => _loadingWeather = true);
    _loadWeather();
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  IconData _weatherIcon(String condition) {
    switch (condition) {
      case 'Rainy':
        return Icons.water_drop_outlined;
      case 'Cold':
        return Icons.ac_unit;
      case 'Hot':
        return Icons.local_fire_department_outlined;
      case 'Sunny':
        return Icons.wb_sunny_outlined;
      default:
        return Icons.cloud_outlined;
    }
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final List<Color> colors;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.colors, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(height: 8),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11)),
          ],
        ),
      ),
    );
  }
}
