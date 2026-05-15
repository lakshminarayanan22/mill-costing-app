import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mill_profile.dart';
import '../models/blend_preset.dart';

// Persists mill profiles to SharedPreferences as JSON.
// Simple enough for the data volumes involved (<10 profiles typically).
class StorageService {
  static const _profilesKey = 'mill_profiles';
  static const _activeProfileKey = 'active_profile_id';

  final SharedPreferences _prefs;
  StorageService(this._prefs);

  List<MillProfile> loadProfiles() {
    final raw = _prefs.getString(_profilesKey);
    if (raw == null) return [MillProfile.rst2];
    try {
      final list = jsonDecode(raw) as List;
      final profiles =
          list.map((e) => MillProfile.fromJson(e as Map<String, dynamic>)).toList();
      return profiles.isEmpty ? [MillProfile.rst2] : profiles;
    } catch (_) {
      return [MillProfile.rst2];
    }
  }

  Future<void> saveProfiles(List<MillProfile> profiles) async {
    final json = jsonEncode(profiles.map((p) => p.toJson()).toList());
    await _prefs.setString(_profilesKey, json);
  }

  String? get activeProfileId => _prefs.getString(_activeProfileKey);

  Future<void> setActiveProfileId(String id) async {
    await _prefs.setString(_activeProfileKey, id);
  }

  Future<void> saveProfile(MillProfile profile, List<MillProfile> all) async {
    final updated = [
      for (final p in all)
        if (p.id == profile.id) profile else p,
    ];
    if (!updated.any((p) => p.id == profile.id)) {
      updated.add(profile);
    }
    await saveProfiles(updated);
  }

  Future<void> deleteProfile(String id, List<MillProfile> all) async {
    final updated = all.where((p) => p.id != id).toList();
    await saveProfiles(updated);
  }

  // ── Blend presets ───────────────────────────────────────────────────────────
  static const _blendsKey = 'blend_presets';

  List<BlendPreset> loadBlendPresets() {
    final raw = _prefs.getString(_blendsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => BlendPreset.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveBlendPresets(List<BlendPreset> presets) async {
    await _prefs.setString(
        _blendsKey, jsonEncode(presets.map((p) => p.toJson()).toList()));
  }

  Future<void> saveBlendPreset(BlendPreset preset, List<BlendPreset> all) async {
    final updated = [
      for (final p in all)
        if (p.id == preset.id) preset else p,
      if (!all.any((p) => p.id == preset.id)) preset,
    ];
    await saveBlendPresets(updated);
  }

  Future<void> deleteBlendPreset(String id, List<BlendPreset> all) async {
    await saveBlendPresets(all.where((p) => p.id != id).toList());
  }
}
