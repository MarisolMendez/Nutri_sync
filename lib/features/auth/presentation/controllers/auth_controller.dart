import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/di/providers.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import 'auth_state.dart';

/// Provider que expone el AuthController a toda la app.
/// Los widgets lo observan con ref.watch(authControllerProvider).
final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(
  () => AuthController(
    loginUseCase: sl(),
    logoutUseCase: sl(),
    registerUseCase: sl(),
    getCurrentUserUseCase: sl(),
  ),
);

class AuthController extends Notifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RegisterUseCase _registerUseCase;
  final GetCurrentUserUseCase _getCurrentUserUseCase;

  AuthController({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required RegisterUseCase registerUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _registerUseCase = registerUseCase,
        _getCurrentUserUseCase = getCurrentUserUseCase;

  @override
  AuthState build() {
    return const AuthInitial();
  }

  /// Verifica si hay una sesión activa guardada en SharedPreferences.
  /// Si existe, emite [AuthAuthenticated]; si no, [AuthUnauthenticated].
  Future<void> checkSession() async {
    state = const AuthLoading();
    final result = await _getCurrentUserUseCase(const NoParams());
    result.fold(
      (_) => state = const AuthUnauthenticated(),
      (user) {
        if (user != null) {
          state = AuthAuthenticated(user);
        } else {
          state = const AuthUnauthenticated();
        }
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    state = const AuthLoading();

    final result = await _loginUseCase(
      LoginParams(email: email, password: password),
    );

    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
  }) async {
    state = const AuthLoading();

    final result = await _registerUseCase(
      RegisterParams(email: email, password: password, name: name),
    );

    result.fold(
      (failure) => state = AuthError(failure.message),
      (user) => state = AuthAuthenticated(user),
    );
  }

  Future<void> logout() async {
    state = const AuthLoading();

    final result = await _logoutUseCase(const NoParams());

    result.fold(
      (failure) => state = AuthError(failure.message),
      (_) => state = const AuthUnauthenticated(),
    );
  }
}