import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:studybytes/features/auth/models/user_model.dart';

class SupabaseAuthService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Obtener usuario actual
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return null;

      final userId = session.user.id;
      return await _getUserProfile(userId);
    } catch (e, stackTrace) {
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
        debugPrint('signIn: Perfil no encontrado para user_id: ${response.user!.id}');
        return null;
      }

      debugPrint('Usuario autenticado: ${user.email}');
      return user;
    } catch (e, stackTrace) {
      debugPrint('Error en signInWithEmail: $e');
      throw Exception(_getUserFriendlyMessage(e));
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
        debugPrint('signUp: response.user es null');
        throw Exception('Error al crear el usuario');
      }

      final userId = response.user!.id;
      final session = _supabase.auth.currentSession;

      // Estrategia 1: Si hay sesión activa (email confirmation OFF)
      if (session != null && session.user.id == userId) {
        try {
          await _createUserProfile(userId, email, name);
          final user = await _getUserProfile(userId);
          if (user != null) {
            debugPrint('Usuario registrado con sesión activa: $email');
            return user;
          }
        } catch (insertError) {
          debugPrint('Error insertando perfil con sesión: $insertError');
        }
      }
      
      // Estrategia 2: Sin sesión activa (email confirmation ON)
      await Future.delayed(const Duration(seconds: 1));
      
      var userProfile = await _getUserProfile(userId);
      if (userProfile != null) {
        debugPrint('Usuario registrado (perfil creado por trigger): $email');
        return userProfile;
      }
      
      // Estrategia 3: Intentar crear manualmente
      try {
        await _createUserProfile(userId, email, name);
        userProfile = await _getUserProfile(userId);
        if (userProfile != null) {
          debugPrint('Usuario registrado (inserción manual): $email');
          return userProfile;
        }
      } catch (finalError) {
        debugPrint('Error final creando perfil: $finalError');
      }
      
      throw Exception('Registro exitoso. Por favor verifica tu correo electrónico.');
      
    } catch (e, stackTrace) {
      debugPrint('Error en signUpWithEmail: $e');
      throw Exception(_getUserFriendlyMessage(e));
    }
  }

  // Método auxiliar para crear perfil
  Future<void> _createUserProfile(String userId, String email, String name) async {
    await _supabase.from('profiles').insert({
      'user_id': userId,
      'email': email,
      'name': name,
      'is_premium': false,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  // Obtener perfil de usuario
  Future<UserModel?> _getUserProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      String email = response['email'] ?? '';
      if (email.isEmpty) {
        final user = _supabase.auth.currentUser;
        email = user?.email ?? '';
      }

      return UserModel(
        id: userId,
        email: email,
        name: response['name'] ?? '',
        photoUrl: response['photo_url'],
        isPremium: response['is_premium'] ?? false,
        createdAt: DateTime.parse(response['created_at'] ?? DateTime.now().toIso8601String()),
        premiumUntil: response['premium_until'] != null
            ? DateTime.parse(response['premium_until'])
            : null,
      );
    } catch (e, stackTrace) {
      debugPrint('Error en _getUserProfile: $e');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      debugPrint('Sesión cerrada');
    } catch (e, stackTrace) {
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
      
      debugPrint('Usuario $userId actualizado a premium');
    } catch (e, stackTrace) {
      debugPrint('Error en upgradeToPremium: $e');
    }
  }

  // Mensajes amigables para el usuario
  String _getUserFriendlyMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    
    if (errorStr.contains('invalid login credentials') || 
        errorStr.contains('invalid credentials')) {
      return 'Correo electrónico o contraseña incorrectos';
    }
    if (errorStr.contains('email not confirmed')) {
      return 'Por favor verifica tu correo electrónico antes de iniciar sesión';
    }
    if (errorStr.contains('user already registered')) {
      return 'Este correo ya está registrado. Por favor inicia sesión';
    }
    if (errorStr.contains('row-level security') || errorStr.contains('rls')) {
      return 'Error de permisos. Por favor contacta soporte';
    }
    if (errorStr.contains('network')) {
      return 'Error de conexión. Verifica tu internet';
    }
    
    return 'Error: ${error.toString()}';
  }
}