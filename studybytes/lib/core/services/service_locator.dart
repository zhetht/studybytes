import '../../features/auth/services/supabase_auth_service.dart';
import 'supabase_service.dart';

/// Simple Service Locator para evitar instanciar múltiples SupabaseAuthService.
class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  SupabaseAuthService? _authService;
  SupabaseService? _supabaseService;

  SupabaseAuthService get authService => _authService!;
  SupabaseService get supabaseService => _supabaseService!;

  /// Inicializa los servicios (se llama una sola vez desde main).
  void init() {
    _authService ??= SupabaseAuthService();
    _supabaseService ??= SupabaseService(authService: _authService!);
  }
}


