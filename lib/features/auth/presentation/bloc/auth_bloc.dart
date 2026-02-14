import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/login_model.dart';
import '../../data/models/register_model.dart';
import '../../data/services/auth_api_service.dart';
import '../../data/services/auth_local_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthApiService _apiService;
  final AuthLocalService _localService;

  AuthBloc({
    required AuthApiService apiService,
    required AuthLocalService localService,
  }) : _apiService = apiService,
       _localService = localService,
       super(const AuthState()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final request = LoginRequest(
        email: event.email,
        password: event.password,
      );

      final response = await _apiService.login(request);

      // Save token and user data locally
      await _localService.saveToken(response.token);
      await _localService.saveUserId(response.user.id ?? '');
      await _localService.saveUserEmail(response.user.email);

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          user: response.user,
          token: response.token,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));

    try {
      final request = RegisterRequest(
        name: event.name,
        username: event.username,
        email: event.email,
        password: event.password,
        passwordRepeat: event.passwordRepeat,
        profilePictureUrl: event.profilePictureUrl,
        phoneNumber: event.phoneNumber,
        bio: event.bio,
        website: event.website,
      );

      await _apiService.register(request);

      // After successful registration, automatically login
      add(LoginRequested(email: event.email, password: event.password));
    } catch (e) {
      emit(
        state.copyWith(
          status: AuthStatus.error,
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      final token = await _localService.getToken();
      if (token != null) {
        await _apiService.logout(token);
      }
    } catch (e) {
      // Continue with logout even if API call fails
    } finally {
      await _localService.clearAuthData();
      emit(const AuthState(status: AuthStatus.unauthenticated));
    }
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final token = await _localService.getToken();

    if (token != null && token.isNotEmpty) {
      emit(state.copyWith(status: AuthStatus.authenticated, token: token));
    } else {
      emit(state.copyWith(status: AuthStatus.unauthenticated));
    }
  }
}
