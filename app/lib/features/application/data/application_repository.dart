import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/application.dart';

class ApplicationRepository {
  const ApplicationRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _storageKey = 'job_applications_json';

  List<JobApplication> load() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded
          .map((e) => JobApplication.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<JobApplication> applications) async {
    await _prefs.setString(
      _storageKey,
      jsonEncode(applications.map((a) => a.toJson()).toList()),
    );
  }
}
