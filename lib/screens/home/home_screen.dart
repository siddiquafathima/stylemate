import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../wardrobe/wardrobe_screen.dart';
import '../outfit/create_outfit_screen.dart';
import '../calendar/calendar_screen.dart';
import '../profile/profile_screen.dart';
import 'home_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final _tabs = const [
    HomeTab(),
    WardrobeScreen(),
    CreateOutfitScreen(),
    CalendarScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Icon shapes follow the theme: outlined (beige), rounded (pink),
    // sharp (blue & black).
    final style = context.watch<ThemeProvider>().palette.iconStyle;
    return Scaffold(
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(icon: Icon(AppIcons.home(style)), label: 'Home'),
          NavigationDestination(icon: Icon(AppIcons.wardrobe(style)), label: 'Wardrobe'),
          NavigationDestination(icon: Icon(AppIcons.outfits(style)), label: 'Outfits'),
          NavigationDestination(icon: Icon(AppIcons.calendar(style)), label: 'Calendar'),
          NavigationDestination(icon: Icon(AppIcons.profile(style)), label: 'Profile'),
        ],
      ),
    );
  }
}
