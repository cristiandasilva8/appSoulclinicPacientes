import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

// Events
abstract class AuthEvent {}

class LoginRequested extends AuthEvent {
  final String cpf;
  final String senha;
  final String dbGroup;

  LoginRequested({
    required this.cpf,
    required this.senha,
    required this.dbGroup,
  });
}

class LogoutRequested extends AuthEvent {}

class CheckAuthStatus extends AuthEvent {}

class RefreshTokenRequested extends AuthEvent {}

// States
abstract class AuthState {}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  AuthAuthenticated({required this.user});
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  AuthError({required this.message});
}

// Bloc
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService = AuthService();

  AuthBloc() : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
    on<RefreshTokenRequested>(_onRefreshTokenRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final response = await _authService.login(
        cpf: event.cpf,
        senha: event.senha,
        dbGroup: event.dbGroup,
      );

      if (response.success && response.data != null) {
        emit(AuthAuthenticated(user: response.data!.user));
      } else {
        emit(AuthError(message: response.message));
      }
    } catch (e) {
      emit(AuthError(message: 'Erro de conexão: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      await _authService.logout();
      emit(AuthUnauthenticated());
    } catch (e) {
      // Mesmo com erro, consideramos logout realizado
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());

    try {
      final isAuthenticated = await _authService.isAuthenticated();
      
      if (isAuthenticated) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onRefreshTokenRequested(
    RefreshTokenRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final response = await _authService.refreshToken();
      
      if (response.success) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          emit(AuthAuthenticated(user: user));
        } else {
          emit(AuthUnauthenticated());
        }
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }
}
