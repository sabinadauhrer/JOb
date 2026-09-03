import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const defaultBackendUrl = 'http://localhost:3000';
const backendUrlPrefsKey = 'backend_base_url';
const authTokenStorageKey = 'auth_token';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final backendUrlProvider = StateProvider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString(backendUrlPrefsKey) ?? defaultBackendUrl;
});

/// Holds the current auth token in memory so the Dio interceptor can attach
/// it synchronously; the token is persisted separately in secure storage.
final authTokenProvider = StateProvider<String?>((ref) => null);

final dioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(backendUrlProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: '$baseUrl/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ),
  );
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) {
        final token = ref.read(authTokenProvider);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        handler.next(options);
      },
    ),
  );
  return dio;
});

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;

  factory ApiException.fromDioException(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['error'] is String) {
      return ApiException(data['error'] as String);
    }
    return ApiException(e.message ?? 'Netzwerkfehler');
  }
}
