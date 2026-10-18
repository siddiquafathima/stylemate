import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../services/auth_service.dart';
import '../home/home_screen.dart';

/// One-step onboarding. Tapping Female / Male / Neutral immediately
/// applies that theme to this very screen (pink / blue & black / beige),
/// so the user sees what they are choosing. No separate theme picker.
class PersonalizeScreen extends StatefulWidget {
  const PersonalizeScreen({super.key});

  @override
  State<PersonalizeScreen> createState() => _PersonalizeScreenState();
}

class _PersonalizeScreenState extends State<PersonalizeScreen> {
  String? _selectedGender;

  void _pick(String gender) {
    setState(() => _selectedGender = gender);
    context.read<ThemeProvider>().setDefaultForGender(gender);
  }

  void _finish() {
    final themeProvider = context.read<ThemeProvider>();
    context.read<AuthService>().updateGenderAndTheme(_selectedGender ?? 'neutral', themeProvider.palette.key);
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<ThemeProvider>().palette;
    final ink = palette.textPrimary;

    return Scaffold(
      appBar: AppBar(title: const Text('Personalize')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(palette.radius),
                  border: Border.all(color: ink.withOpacity(0.12)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.asset('assets/images/personalize_couple.png', fit: BoxFit.cover),
              ),
              const SizedBox(height: 18),
              Text('Help us know you better', style: AppType.heading(palette.headingFont, ink, size: 24)),
              const SizedBox(height: 6),
              Text(
                'Pick one -- the app instantly changes to match.',
                style: TextStyle(color: ink.withOpacity(0.65), fontSize: 13),
              ),
              const SizedBox(height: 18),
              _GenderCard(
                label: 'Female',
                subtitle: 'Pink theme',
                icon: Icons.female,
                selected: _selectedGender == 'female',
                onTap: () => _pick('female'),
              ),
              const SizedBox(height: 12),
              _GenderCard(
                label: 'Male',
                subtitle: 'Blue & black theme',
                icon: Icons.male,
                selected: _selectedGender == 'male',
                onTap: () => _pick('male'),
              ),
              const SizedBox(height: 12),
              _GenderCard(
                label: 'Neutral',
                subtitle: 'Beige theme',
                icon: Icons.person_outline,
                selected: _selectedGender == 'neutral',
                onTap: () => _pick('neutral'),
              ),
              const SizedBox(height: 16),
              // Live preview of the theme being chosen.
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(palette.radius),
                  border: Border.all(color: palette.primary.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    Text('Your theme', style: TextStyle(color: ink.withOpacity(0.6), fontSize: 12)),
                    const Spacer(),
                    _dot(palette.primary),
                    const SizedBox(width: 6),
                    _dot(palette.secondary),
                    const SizedBox(width: 6),
                    _dot(palette.accent),
                    const SizedBox(width: 12),
                    Text(palette.displayName, style: const TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _selectedGender == null ? null : _finish,
                child: const Text('Continue'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot(Color color) => Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
      );
}

class _GenderCard extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _GenderCard({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: selected ? primary : Colors.transparent, width: 2),
      ),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: primary.withOpacity(0.12), child: Icon(icon, color: primary)),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: Icon(selected ? Icons.radio_button_checked : Icons.radio_button_off, color: selected ? primary : Colors.grey),
        onTap: onTap,
      ),
    );
  }
}
