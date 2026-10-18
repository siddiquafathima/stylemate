import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Auth service with lightweight LOCAL persistence via SharedPreferences
/// (stored on-device only -- not a real backend, but survives closing
/// the app, unlike the previous pure in-memory version).
///
/// To go live with Firebase later: replace the SharedPreferences reads
/// and writes below with FirebaseAuth + Firestore calls -- the public
/// method signatures (signUp/logIn/sendPasswordReset/etc.) can stay
/// exactly the same, so no screen code needs to change.
class AuthService extends ChangeNotifier {
  UserModel? currentUser;

  bool get isLoggedIn => currentUser != null;

  final Map<String, String> _passwordsByEmail = {};
  final Map<String, UserModel> _usersByEmail = {};

  static const _usersKey = 'stylemate_users_v1';
  static const _currentEmailKey = 'stylemate_current_email_v1';

  /// Call this once at app startup, before runApp, to restore any
  /// previously saved accounts and session.
  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final usersJson = prefs.getString(_usersKey);
    if (usersJson != null) {
      final List<dynamic> list = jsonDecode(usersJson);
      for (final item in list) {
        final email = item['email'] as String;
        final user = UserModel(
          id: email,
          name: item['name'] as String,
          email: email,
          gender: item['gender'] as String? ?? 'unspecified',
          themeKey: item['themeKey'] as String? ?? 'neutral',
          autoApplyAiTags: item['autoApplyAiTags'] as bool? ?? false,
        );
        _usersByEmail[email] = user;
        _passwordsByEmail[email] = item['password'] as String;
      }
    }
    final currentEmail = prefs.getString(_currentEmailKey);
    if (currentEmail != null && _usersByEmail.containsKey(currentEmail)) {
      currentUser = _usersByEmail[currentEmail];
    }
    notifyListeners();
  }

  Future<void> _persistUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final list = _usersByEmail.values
        .map((u) => {
              'email': u.email,
              'name': u.name,
              'password': _passwordsByEmail[u.email],
              'gender': u.gender,
              'themeKey': u.themeKey,
              'autoApplyAiTags': u.autoApplyAiTags,
            })
        .toList();
    await prefs.setString(_usersKey, jsonEncode(list));
  }

  Future<void> _persistCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    if (currentUser == null) {
      await prefs.remove(_currentEmailKey);
    } else {
      await prefs.setString(_currentEmailKey, currentUser!.email);
    }
  }

  Future<String?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (_usersByEmail.containsKey(email)) {
      return 'An account with this email already exists.';
    }
    final user = UserModel(id: email, name: name, email: email);
    _usersByEmail[email] = user;
    _passwordsByEmail[email] = password;
    currentUser = user;
    await _persistUsers();
    await _persistCurrentUser();
    notifyListeners();
    return null;
  }

  Future<String?> logIn({required String email, required String password}) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!_usersByEmail.containsKey(email) || _passwordsByEmail[email] != password) {
      return 'Incorrect email or password.';
    }
    currentUser = _usersByEmail[email];
    await _persistCurrentUser();
    notifyListeners();
    return null;
  }

  Future<String?> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (!_usersByEmail.containsKey(email)) {
      return 'No account found with this email.';
    }
    // TODO: replace with FirebaseAuth.instance.sendPasswordResetEmail(email: email)
    return null;
  }

  void updateGenderAndTheme(String gender, String themeKey) {
    currentUser?.gender = gender;
    currentUser?.themeKey = themeKey;
    _persistUsers();
    notifyListeners();
  }

  void setAutoApplyAiTags(bool value) {
    currentUser?.autoApplyAiTags = value;
    _persistUsers();
    notifyListeners();
  }

  Future<void> logOut() async {
    currentUser = null;
    await _persistCurrentUser();
    notifyListeners();
  }
}
