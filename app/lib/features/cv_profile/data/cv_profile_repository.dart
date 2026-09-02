import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/cv_profile.dart';

class CvProfileRepository {
  const CvProfileRepository(this._prefs);

  final SharedPreferences _prefs;

  static const _storageKey = 'cv_profile_json';

  CvProfile load() {
    final raw = _prefs.getString(_storageKey);
    if (raw == null) return CvProfile.empty;
    try {
      return CvProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return CvProfile.empty;
    }
  }

  Future<void> save(CvProfile profile) async {
    await _prefs.setString(_storageKey, jsonEncode(profile.toJson()));
  }
}
