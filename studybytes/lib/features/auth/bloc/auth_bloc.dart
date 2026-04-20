import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/user_model.dart';
import '../services/supabase_auth_service.dart';

// Events
abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequested(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;
  AuthRegisterRequested(this.email, this.password, this.name);
  @override
  List<Object?> get props => [email, password, name];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthUpgradePremium extends AuthEvent {}

// States
abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}
class AuthLoading extends AuthState {}
class AuthAuthenticated extends AuthState {
  final UserModel user;
  AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}
class AuthUnauthenticated extends AuthState {}
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
  @override
  List<Object?> get props => [message];
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
final SupabaseAuthService _authService;

  AuthBloc(this._authService) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUpgradePremium>(_onUpgradePremium);
  }

  Future<void> _onCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final user = await _authService.getCurrentUser();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final user =
        await _authService.signInWithEmail(event.email, event.password);
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthError('Correo o contraseña incorrectos'));
    }
  }

  Future<void> _onRegisterRequested(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(AuthLoading());
    final user = await _authService.signUpWithEmail(
        event.email, event.password, event.name);
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthError('El correo ya está registrado'));
    }
  }

  Future<void> _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    await _authService.signOut();
    emit(AuthUnauthenticated());
  }

  Future<void> _onUpgradePremium(
      AuthUpgradePremium event, Emitter<AuthState> emit) async {
    if (state is AuthAuthenticated) {
      final current = (state as AuthAuthenticated).user;
      await _authService.upgradeToPremium(current.id);
      emit(AuthAuthenticated(current.copyWith(isPremium: true)));
    }
  }
}
