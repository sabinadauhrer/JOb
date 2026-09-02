import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const defaultBackendUrl = 'http://localhost:3000';
const backendUrlPrefsKey = 'backend_base_url';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden in main()');
});

final backendUrlProvider = StateProvider<String>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getString(backendUrlPrefsKey) ?? defaultBackendUrl;
});

final dioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.watch(backendUrlProvider);
  return Dio(
    BaseOptions(
      baseUrl: '$baseUrl/api',
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 60),
      headers: {'Content-Type': 'application/json'},
    ),
  );
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
