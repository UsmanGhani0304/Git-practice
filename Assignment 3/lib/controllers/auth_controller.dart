import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../enums/auth_status.dart';
import '../enums/gender.dart';
import '../models/app_user.dart';

class AuthController extends ChangeNotifier {
  static const _rememberedKey = 'remembered_user';
  static const _firstNameKey = 'first_name';
  static const _lastNameKey = 'last_name';
  static const _emailKey = 'email';
  static const _genderKey = 'gender';
  static const _passwordKey = 'password';

  AppUser? _registeredUser;
  AuthStatus _status = AuthStatus.unauthenticated;
  bool _isRemembered = false;

  AppUser? get registeredUser => _registeredUser;
  AppUser? get currentUser => _status == AuthStatus.authenticated
      ? _registeredUser
      : null;
  AuthStatus get status => _status;
  bool get isRemembered => _isRemembered;

  Future<void> registerUser({
    required String firstName,
    required String lastName,
    required String email,
    required Gender gender,
    required String password,
  }) async {
    _registeredUser = AppUser(
      firstName: firstName.trim(),
      lastName: lastName.trim(),
      email: email.trim(),
      gender: gender,
      password: password,
    );
    _status = AuthStatus.unauthenticated;
    await _saveUser(_registeredUser!);
    notifyListeners();
  }

  Future<AppUser?> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    await _loadStoredUser();
    final user = _registeredUser;
    final isValid = user != null &&
        user.email.toLowerCase() == email.trim().toLowerCase() &&
        user.password == password;

    if (!isValid) return null;

    _status = AuthStatus.authenticated;
    _isRemembered = rememberMe;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_rememberedKey, rememberMe);
    notifyListeners();
    return user;
  }

  Future<void> logout() async {
    _status = AuthStatus.unauthenticated;
    _isRemembered = false;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_rememberedKey, false);
    notifyListeners();
  }

  Future<void> loadRememberedSession() async {
    final preferences = await SharedPreferences.getInstance();
    _isRemembered = preferences.getBool(_rememberedKey) ?? false;
    await _loadStoredUser();
    if (_isRemembered && _registeredUser != null) {
      _status = AuthStatus.authenticated;
    }
  }

  Future<void> _saveUser(AppUser user) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_firstNameKey, user.firstName);
    await preferences.setString(_lastNameKey, user.lastName);
    await preferences.setString(_emailKey, user.email);
    await preferences.setString(_genderKey, user.gender.name);
    await preferences.setString(_passwordKey, user.password);
  }

  Future<void> _loadStoredUser() async {
    final preferences = await SharedPreferences.getInstance();
    final email = preferences.getString(_emailKey);
    if (email == null || email.isEmpty) return;

    _registeredUser = AppUser.fromMap({
      'firstName': preferences.getString(_firstNameKey) ?? '',
      'lastName': preferences.getString(_lastNameKey) ?? '',
      'email': email,
      'gender': preferences.getString(_genderKey) ?? Gender.other.name,
      'password': preferences.getString(_passwordKey) ?? '',
    });
  }
}
