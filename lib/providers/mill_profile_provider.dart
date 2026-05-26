import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/mill_profile.dart';
import '../services/storage_service.dart';

// Injected at app start after SharedPreferences is ready
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

final storageServiceProvider = Provider<StorageService>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

// List of all saved mill profiles
final millProfilesProvider =
    StateNotifierProvider<MillProfilesNotifier, List<MillProfile>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return MillProfilesNotifier(storage, storage.loadProfiles());
});

class MillProfilesNotifier extends StateNotifier<List<MillProfile>> {
  final StorageService _storage;

  MillProfilesNotifier(this._storage, super.initial);

  Future<void> save(MillProfile profile) async {
    await _storage.saveProfile(profile, state);
    state = [
      for (final p in state)
        if (p.id == profile.id) profile else p,
      if (!state.any((p) => p.id == profile.id)) profile,
    ].toList();
  }

  Future<void> delete(String id) async {
    await _storage.deleteProfile(id, state);
    state = state.where((p) => p.id != id).toList();
  }
}

// Currently selected mill profile
final activeMillProvider =
    StateNotifierProvider<ActiveMillNotifier, MillProfile>((ref) {
  final profiles = ref.watch(millProfilesProvider);
  final storage = ref.read(storageServiceProvider);
  final savedId = storage.activeProfileId;
  final initial = profiles.firstWhere(
    (p) => p.id == savedId,
    orElse: () => profiles.first,
  );
  return ActiveMillNotifier(storage, initial);
});

class ActiveMillNotifier extends StateNotifier<MillProfile> {
  final StorageService _storage;

  ActiveMillNotifier(this._storage, super.initial);

  Future<void> select(MillProfile mill) async {
    state = mill;
    await _storage.setActiveProfileId(mill.id);
  }
}
