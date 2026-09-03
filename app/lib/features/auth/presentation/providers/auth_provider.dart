import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../core/network/dio_client.dart';
import '../../data/auth_remote_data_source.dart';
import '../../domain/auth_user.dart';

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(ref.watch(dioProvider));
});

sealed class AuthState {
  const AuthState();
}

class AuthUnknown extends AuthState {
  const AuthUnknown();
}

class AuthLoggedOut extends AuthState {
  const AuthLoggedOut();
}

class AuthLoggedIn extends AuthState {
  const AuthLoggedIn(this.user);
  final AuthUser user;
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._ref) : super(const AuthUnknown()) {
    _restoreSession();
  }

  final Ref _ref;

  Future<void> _restoreSession() async {
    final storage = _ref.read(secureStorageProvider);
    final token = await storage.read(key: authTokenStorageKey);
    if (token == null) {
      state = const AuthLoggedOut();
      return;
    }
    _ref.read(authTokenProvider.notifier).state = token;
    state = AuthLoggedIn(AuthUser(id: '', email: '', token: token));
  }

  Future<String?> register({required String email, required String password}) async {
    try {
      final user = await _ref.read(authRemoteDataSourceProvider).register(
        email: email,
        password: password,
      );
      await _persistSession(user);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<String?> login({required String email, required String password}) async {
    try {
      final user = await _ref.read(authRemoteDataSourceProvider).login(
        email: email,
        password: password,
      );
      await _persistSession(user);
      return null;
    } on ApiException catch (e) {
      return e.message;
    }
  }

  Future<void> logout() async {
    await _ref.read(secureStorageProvider).delete(key: authTokenStorageKey);
    _ref.read(authTokenProvider.notifier).state = null;
    state = const AuthLoggedOut();
  }

  Future<void> _persistSession(AuthUser user) async {
    await _ref.read(secureStorageProvider).write(key: authTokenStorageKey, value: user.token);
    _ref.read(authTokenProvider.notifier).state = user.token;
    state = AuthLoggedIn(user);
  }
}
