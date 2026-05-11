import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener usuario actual
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return null;

      final userId = session.user.id;
      return await _getUserProfile(userId);
    } catch (e) {
      debugPrint('Error en getCurrentUser: $e');
      return null;
    }
  }

  // Iniciar sesión
  Future<UserModel?> signInWithEmail(String email, String password) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        debugPrint('signIn: response.user es null');
        return null;
      }

      final user = await _getUserProfile(response.user!.id);
      if (user == null) {
        debugPrint('signIn: Perfil no encontrado');
        return null;
      }

      return user;
    } catch (e) {
      debugPrint('Error en signInWithEmail: $e');
      rethrow;
    }
  }

  // Registrar usuario
  Future<UserModel?> signUpWithEmail(String email, String password, String name) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw Exception('Error al crear el usuario');
      }

      final userId = response.user!.id;
      
      // Intentar crear el perfil
      try {
        await _createUserProfile(userId, email, name);
      } catch (e) {
        debugPrint('Error creando perfil (puede ser RLS o email sin confirmar): $e');
      }
      
      // Esperar un momento para que el trigger o RLS procese
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Obtener el perfil
      final user = await _getUserProfile(userId);
      
      if (user != null) {
        return user;
      }
      
      // Si no hay perfil pero el usuario existe, puede ser por email no confirmado
      if (_supabase.auth.currentSession == null) {
        throw Exception('Por favor verifica tu correo electrónico antes de continuar');
      }
      
      return null;
      
    } catch (e) {
      debugPrint('Error en signUpWithEmail: $e');
      rethrow;
    }
  }

  // Crear perfil
  Future<void> _createUserProfile(String userId, String email, String name) async {
    await _supabase.from('profiles').insert({
      'user_id': userId,
      'email': email,
      'name': name,
      'is_premium': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Obtener perfil
  Future<UserModel?> _getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return UserModel(
        id: userId,
        email: response['email'] ?? '',
        name: response['name'] ?? '',
        photoUrl: response['photo_url'],
        isPremium: response['is_premium'] ?? false,
        createdAt: DateTime.parse(response['created_at'] ?? DateTime.now().toIso8601String()),
        premiumUntil: response['premium_until'] != null
            ? DateTime.parse(response['premium_until'])
            : null,
      );
    } catch (e) {
      debugPrint('Error en _getUserProfile: $e');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
    } catch (e) {
      debugPrint('Error en signOut: $e');
    }
  }

  // Upgrade a premium
  Future<void> upgradeToPremium(String userId) async {
    try {
      await _supabase.from('profiles').update({
        'is_premium': true,
        'premium_until': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      }).eq('user_id', userId);
    } catch (e) {
      debugPrint('Error en upgradeToPremium: $e');
      rethrow;
    }
  }
}