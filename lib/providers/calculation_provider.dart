import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/calculation_input.dart';
import '../models/calculation_result.dart';
import '../models/count_bracket.dart';
import '../engine/costing_engine.dart';
import 'mill_profile_provider.dart';

// The live form state — updated as user types
final calculationInputProvider =
    StateNotifierProvider<CalculationInputNotifier, CalculationInput>((ref) {
  final mill = ref.watch(activeMillProvider);
  // Auto-fill bracket for count=94 (reference scenario default)
  final bracket =
      mill.bracketFor(94) ?? kDefaultBrackets[5]; // bracket 6
  return CalculationInputNotifier(CalculationInput.reference(bracket));
});

class CalculationInputNotifier extends StateNotifier<CalculationInput> {
  CalculationInputNotifier(super.initial);

  void update(CalculationInput updated) => state = updated;

  // Called when user changes the count — auto-fills bracket from active mill
  void onCountChanged(double count, CountBracket? bracket) {
    if (bracket == null) return;
    state = state.copyWith(
      resultantCount: count,
      bracket: bracket,
      // Also update comber noil from bracket default
      comberNoilPct: bracket.comberNoilPct,
    );
  }

  void onPriceModeToggle(String mode) {
    state = state.copyWith(priceMode: mode);
  }
}

// Computed result — recalculated whenever input or mill changes
final calculationResultProvider =
    Provider<AsyncValue<CalculationResult>>((ref) {
  final input = ref.watch(calculationInputProvider);
  final mill = ref.watch(activeMillProvider);
  try {
    final result = CostingEngine.calculate(input, mill);
    return AsyncValue.data(result);
  } catch (e, st) {
    return AsyncValue.error(e, st);
  }
});
