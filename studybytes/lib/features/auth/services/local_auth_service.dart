import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../../../core/constants/app_constants.dart';

class LocalAuthService {
  final Map<String, UserModel> _users = {};
  UserModel? _currentUser;
  final _userController = StreamController<UserModel?>.broadcast();

  Stream<UserModel?> get userChanges => _userController.stream;

  LocalAuthService() {
    _loadMockUsers();
    _initSession();
  }

  void _loadMockUsers() {
    _users['ghosty@studybytes.com'] = UserModel(
      id: 'user_001',
      email: 'ghosty@studybytes.com',
      name: 'Ghosty',
      createdAt: DateTime.now(),
      isPremium: true,
    );
    _users['test@example.com'] = UserModel(
      id: 'user_002',
      email: 'test@example.com',
      name: 'Usuario Test',
      createdAt: DateTime.now(),
    );
  }

  Future<void> _initSession() async {
    await getCurrentUser();
    _userController.add(_currentUser);
  }

  Future<UserModel?> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final user = _users[email.toLowerCase()];
    if (user != null && password == AppConstants.mockPassword) {
      await _saveSession(user);
      _currentUser = user;
      _userController.add(user);
      return user;
    }
    return null;
  }

  Future<UserModel?> signUpWithEmail(
      String email, String password, String name) async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (_users.containsKey(email.toLowerCase())) return null;

    final newUser = UserModel(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );

    _users[email.toLowerCase()] = newUser;
    await _saveSession(newUser);
    _currentUser = newUser;
    _userController.add(newUser);
    return newUser;
  }

  Future<void> _saveSession(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyIsLoggedIn, true);
    await prefs.setString(AppConstants.keyUserId, user.id);
    await prefs.setString(AppConstants.keyUserEmail, user.email);
    await prefs.setString(AppConstants.keyUserName, user.name);
    await prefs.setBool(AppConstants.keyUserPremium, user.isPremium);
  }

  Future<void> signOut() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    _currentUser = null;
    _userController.add(null);
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
  }

  Future<UserModel?> getCurrentUser() async {
    if (_currentUser != null) return _currentUser;
    final prefs = await SharedPreferences.getInstance();
    final loggedIn = prefs.getBool(AppConstants.keyIsLoggedIn) ?? false;
    if (loggedIn) {
      _currentUser = UserModel(
        id: prefs.getString(AppConstants.keyUserId) ?? '',
        email: prefs.getString(AppConstants.keyUserEmail) ?? '',
        name: prefs.getString(AppConstants.keyUserName) ?? '',
        createdAt: DateTime.now(),
        isPremium: prefs.getBool(AppConstants.keyUserPremium) ?? false,
      );
    }
    return _currentUser;
  }

  Future<void> upgradeToPremium(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.keyUserPremium, true);
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(isPremium: true);
      _userController.add(_currentUser);
    }
  }

  void dispose() => _userController.close();
}
