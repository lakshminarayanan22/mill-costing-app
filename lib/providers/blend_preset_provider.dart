import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/blend_preset.dart';
import '../services/storage_service.dart';
import 'mill_profile_provider.dart';

final blendPresetsProvider =
    StateNotifierProvider<BlendPresetsNotifier, List<BlendPreset>>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return BlendPresetsNotifier(storage, storage.loadBlendPresets());
});

class BlendPresetsNotifier extends StateNotifier<List<BlendPreset>> {
  final StorageService _storage;

  BlendPresetsNotifier(this._storage, super.initial);

  Future<void> save(BlendPreset preset) async {
    await _storage.saveBlendPreset(preset, state);
    state = [
      for (final p in state)
        if (p.id == preset.id) preset else p,
      if (!state.any((p) => p.id == preset.id)) preset,
    ];
  }

  Future<void> delete(String id) async {
    await _storage.deleteBlendPreset(id, state);
    state = state.where((p) => p.id != id).toList();
  }
}
