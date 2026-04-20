import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class SupabaseAuthService {
  final supabase = Supabase.instance.client;
  UserModel? _currentUser;
  final _userController = StreamController<UserModel?>.broadcast();

  Stream<UserModel?> get userChanges => _userController.stream;

  SupabaseAuthService() {
    supabase.auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session != null) {
        _getUserProfile(session.user.id).then((user) {
          _currentUser = user;
          _userController.add(user);
        });
      } else {
        _currentUser = null;
        _userController.add(null);
      }
    });
    _initSession();
  }

  Future<void> _initSession() async {
    final session = supabase.auth.currentSession;
    if (session != null) {
      _currentUser = await _getUserProfile(session.user.id);
      _userController.add(_currentUser);
    }
  }

  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return await _getUserProfile(response.user!.id);
    } catch (e) {
      return null;
    }
  }

  Future<UserModel?> signUpWithEmail(String email, String password, String name) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );
      await _updateUserProfile(response.user!.id, name);
      return await _getUserProfile(response.user!.id);
    } catch (e) {
      return null;
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final session = supabase.auth.currentSession;
    if (session != null && _currentUser == null) {
      _currentUser = await _getUserProfile(session.user.id);
    }
    return _currentUser;
  }

  Future<UserModel?> _getUserProfile(String userId) async {
    final response = await supabase
        .from('profiles')
        .select('name, is_premium')
        .eq('id', userId)
        .single();
    return UserModel(
      id: userId,
      email: supabase.auth.currentUser?.email ?? '',
      name: response['name'] ?? '',
      isPremium: response['is_premium'] ?? false,
      createdAt: DateTime.now(),
    );
  }

  Future<void> _updateUserProfile(String userId, String name) async {
    await supabase.from('profiles').upsert({
      'id': userId,
      'name': name,
      'is_premium': false,
    });
  }

  Future<void> upgradeToPremium(String userId) async {
    await supabase
        .from('profiles')
        .update({'is_premium': true})
        .eq('id', userId);
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(isPremium: true);
      _userController.add(_currentUser);
    }
  }

  void dispose() => _userController.close();
}
