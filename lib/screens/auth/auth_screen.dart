import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/wardrobe_service.dart';
import '../../theme/app_theme.dart';
import '../../theme/theme_provider.dart';
import '../../widgets/stylemate_wordmark.dart';
import 'forgot_password_screen.dart';
import '../onboarding/personalize_screen.dart';
import '../home/home_screen.dart';

final RegExp _emailPattern = RegExp(r'^[\w\.\-]+@([\w\-]+\.)+[a-zA-Z]{2,}$');

// A plain format check can't catch a real typo like "gmail.coom" -- it's
// still a syntactically valid-looking email. This catches the specific,
// very common case of mistyping a well-known provider's domain.
const Map<String, String> _knownEmailDomains = {
  'gmail': 'gmail.com',
  'yahoo': 'yahoo.com',
  'outlook': 'outlook.com',
  'hotmail': 'hotmail.com',
  'icloud': 'icloud.com',
  'protonmail': 'protonmail.com',
};

String? _domainTypoSuggestion(String email) {
  final atIndex = email.indexOf('@');
  if (atIndex == -1) return null;
  final domain = email.substring(atIndex + 1).toLowerCase();
  for (final entry in _knownEmailDomains.entries) {
    if (domain.startsWith('${entry.key}.') && domain != entry.value) {
      return entry.value;
    }
  }
  return null;
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  bool _loading = false;
  String? _error;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _passwordsMatch = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_checkMatch);
    _confirmController.addListener(_checkMatch);
  }

  void _checkMatch() {
    final match = _confirmController.text.isNotEmpty && _confirmController.text == _passwordController.text;
    if (match != _passwordsMatch) setState(() => _passwordsMatch = match);
  }

  void _switchMode(bool toLogin) {
    setState(() {
      _isLogin = toLogin;
      _error = null;
    });
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    if (!_emailPattern.hasMatch(email)) {
      setState(() => _error = 'Enter a valid email address (e.g. name@example.com).');
      return;
    }
    final domainSuggestion = _domainTypoSuggestion(email);
    if (domainSuggestion != null) {
      setState(() => _error = 'That looks like a typo -- did you mean "...@$domainSuggestion"?');
      return;
    }
    if (!_isLogin && !_passwordsMatch) {
      setState(() => _error = 'Passwords do not match yet.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    final auth = context.read<AuthService>();
    final error = _isLogin
        ? await auth.logIn(email: email, password: _passwordController.text)
        : await auth.signUp(name: _nameController.text.trim(), email: email, password: _passwordController.text);

    setState(() => _loading = false);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    if (!mounted) return;

    final user = auth.currentUser!;
    // Apply this account's theme (pink / blue & black / beige).
    context.read<ThemeProvider>().setDefaultForGender(user.gender);
    // Give this account its own wardrobe -- never share data across users.
    await context.read<WardrobeService>().setUserScope(user.email);
    if (!mounted) return;

    if (user.gender == 'unspecified') {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const PersonalizeScreen()));
    } else {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final palette = context.watch<ThemeProvider>().palette;
    final ink = palette.textPrimary;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              const Center(child: StyleMateWordmark(size: 34)),
              const SizedBox(height: 8),
              Text(
                _isLogin ? 'Welcome back' : 'Create your account',
                textAlign: TextAlign.center,
                style: AppType.heading(palette.headingFont, ink, size: 22),
              ),
              const SizedBox(height: 18),

              // Bag + sunglasses illustration in a soft card.
              Container(
                width: double.infinity,
                height: 170,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(palette.radius),
                  border: Border.all(color: ink.withOpacity(0.14)),
                ),
                child: Image.asset('assets/images/auth_illustration.png', fit: BoxFit.contain),
              ),
              const SizedBox(height: 14),
              Text(
                'Your personal AI-powered digital closet and outfit assistant.',
                textAlign: TextAlign.center,
                style: TextStyle(color: ink.withOpacity(0.65), fontSize: 13),
              ),
              const SizedBox(height: 22),

              // Login / Sign Up toggle
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: ink.withOpacity(0.14)),
                ),
                child: Row(
                  children: [
                    Expanded(child: _ToggleButton(label: 'Login', selected: _isLogin, onTap: () => _switchMode(true))),
                    Expanded(child: _ToggleButton(label: 'Sign Up', selected: !_isLogin, onTap: () => _switchMode(false))),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              if (!_isLogin) ...[
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                ),
                const SizedBox(height: 14),
              ],
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(labelText: 'Email Address', hintText: 'name@example.com'),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              if (_isLogin)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen())),
                    child: const Text('Forgot password?'),
                  ),
                ),
              if (!_isLogin) ...[
                const SizedBox(height: 14),
                TextField(
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: _passwordsMatch ? Colors.green : ink.withOpacity(0.16)),
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                ),
                if (_passwordsMatch)
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Row(children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 16),
                      SizedBox(width: 6),
                      Text('Passwords match', style: TextStyle(color: Colors.green, fontSize: 12)),
                    ]),
                  ),
              ],
              const SizedBox(height: 12),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text(_isLogin ? 'Sign In' : 'Create Account'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _ToggleButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : primary,
          ),
        ),
      ),
    );
  }
}
