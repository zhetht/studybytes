import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../../../core/services/logger_service.dart';

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
      
      final user = await _getUserProfile(response.user!.id);
      AppLogger.info('Usuario autenticado: $email');
      return user;
    } catch (e, stackTrace) {
      AppLogger.error('Error en signInWithEmail: email=$email', e, stackTrace);
      return null;
    }
  }

  Future<UserModel?> signUpWithEmail(String email, String password, String name) async {
    try {
      // 1. Registrar usuario en auth
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      
      if (response.user == null) return null;
      
      // 2. Crear perfil en la tabla 'profiles'
      await supabase.from('profiles').insert({
        'user_id': response.user!.id,  // ← Usar user_id, NO id
        'name': name,
        'is_premium': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      final user = await _getUserProfile(response.user!.id);
      AppLogger.info('Nuevo usuario registrado: $email');
      return user;
    } catch (e, stackTrace) {
      AppLogger.error('Error en signUpWithEmail: email=$email', e, stackTrace);
      return null;
    }
  }

  Future<void> signOut() async {
    await supabase.auth.signOut();
    _currentUser = null;
    _userController.add(null);
  }

  Future<UserModel?> getCurrentUser() async {
    final session = supabase.auth.currentSession;
    if (session == null) {
      AppLogger.warning('Intento de getCurrentUser sin sesión activa');
      return null;
    }
    _currentUser ??= await _getUserProfile(session.user.id);
    return _currentUser;
  }

  Future<UserModel?> _getUserProfile(String userId) async {
    try {
      // Buscar por user_id, NO por id
      final response = await supabase
          .from('profiles')
          .select('name, is_premium')
          .eq('user_id', userId)  // ← CORREGIDO: user_id
          .maybeSingle();  // ← Usar maybeSingle para evitar error si no existe
      
      if (response == null) {
        AppLogger.warning('Perfil no encontrado para userId: $userId');
        return null;
      }
      
      final userEmail = supabase.auth.currentUser?.email ?? '';
      
      return UserModel(
        id: userId,
        email: userEmail,
        name: response['name'] ?? '',
        isPremium: response['is_premium'] ?? false,
        createdAt: DateTime.now(),
      );
    } catch (e, stackTrace) {
      AppLogger.error('Error obteniendo perfil', e, stackTrace);
      return null;
    }
  }

  Future<void> upgradeToPremium(String userId) async {
    await supabase
        .from('profiles')
        .update({'is_premium': true})
        .eq('user_id', userId);  // ← CORREGIDO: user_id
    
    if (_currentUser != null && _currentUser!.id == userId) {
      _currentUser = _currentUser!.copyWith(isPremium: true);
      _userController.add(_currentUser);
    }
    AppLogger.info('Usuario $userId actualizado a premium');
  }

  void dispose() => _userController.close();
}