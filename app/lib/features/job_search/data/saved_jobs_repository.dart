import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/saved_job.dart';

class SavedJobsRepository {
  const SavedJobsRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _storageKey = 'saved_jobs_json';

  List<SavedJob> load() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null) return const [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.map((e) => SavedJob.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return const [];
    }
  }

  Future<void> save(List<SavedJob> jobs) async {
    await _prefs.setString(_storageKey, jsonEncode(jobs.map((j) => j.toJson()).toList()));
  }
}
