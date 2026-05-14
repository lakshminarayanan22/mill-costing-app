import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/calculation_input.dart';
import '../providers/calculation_provider.dart';
import '../providers/mill_profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/label_field.dart';

class CalculatorScreen extends ConsumerStatefulWidget {
  const CalculatorScreen({super.key});

  @override
  ConsumerState<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends ConsumerState<CalculatorScreen> {
  // Controllers for every text field
  late TextEditingController _count;
  late TextEditingController _cotton;
  late TextEditingController _elec;
  late TextEditingController _spindleSpeed;
  late TextEditingController _tm;
  late TextEditingController _utilisation;
  late TextEditingController _packing;
  late TextEditingController _addPacking;
  late TextEditingController _price;
  late TextEditingController _margin;

  // Bracket-editable fields
  late TextEditingController _rfEff;
  late TextEditingController _simplexHank;
  late TextEditingController _simplexSpeed;
  late TextEditingController _simplexTm;
  late TextEditingController _simplexEff;
  late TextEditingController _comberNoil;
  late TextEditingController _windingEff;

  // Waste fields
  late TextEditingController _brWaste;
  late TextEditingController _cardWaste;
  late TextEditingController _yarnWaste;

  // Blend fields
  late TextEditingController _b2Price;
  late TextEditingController _b2Waste;
  late TextEditingController _b2Pct;

  late YarnType _yarnType;
  late String _priceMode;
  late bool _isBlend;

  @override
  void initState() {
    super.initState();
    final inp = ref.read(calculationInputProvider);
    _initControllers(inp);
  }

  void _initControllers(CalculationInput inp) {
    final b = inp.bracket;
    _count = TextEditingController(text: inp.resultantCount.toStringAsFixed(0));
    _cotton = TextEditingController(
        text: inp.cottonPricePerCandy.toStringAsFixed(0));
    _elec = TextEditingController(
        text: inp.electricityRatePerKwh.toStringAsFixed(2));
    _spindleSpeed = TextEditingController(
        text: inp.spindleSpeedRpm.toStringAsFixed(0));
    _tm = TextEditingController(
        text: inp.twistMultiplier.toStringAsFixed(2));
    _utilisation = TextEditingController(
        text: inp.utilisationPct.toStringAsFixed(0));
    _packing = TextEditingController(
        text: inp.packingRatePerKg.toStringAsFixed(2));
    _addPacking = TextEditingController(
        text: inp.additionalPackingForPlied.toStringAsFixed(2));
    _price = TextEditingController(
        text: inp.sellingPricePerKg.toStringAsFixed(0));
    _margin = TextEditingController(
        text: inp.targetMarginPct.toStringAsFixed(1));

    _rfEff = TextEditingController(
        text: (b.ringFrameEfficiency * 100).toStringAsFixed(1));
    _simplexHank =
        TextEditingController(text: b.simplexHank.toStringAsFixed(2));
    _simplexSpeed = TextEditingController(
        text: b.simplexSpeedRpm.toStringAsFixed(0));
    _simplexTm =
        TextEditingController(text: b.simplexTM.toStringAsFixed(2));
    _simplexEff = TextEditingController(
        text: (b.simplexEfficiency * 100).toStringAsFixed(1));
    _comberNoil =
        TextEditingController(text: inp.comberNoilPct.toStringAsFixed(1));
    _windingEff = TextEditingController(
        text: (b.windingEfficiency * 100).toStringAsFixed(1));

    _brWaste =
        TextEditingController(text: inp.blowRoomWastePct.toStringAsFixed(2));
    _cardWaste =
        TextEditingController(text: inp.cardingWastePct.toStringAsFixed(2));
    _yarnWaste =
        TextEditingController(text: inp.yarnWastePct.toStringAsFixed(2));

    _b2Price =
        TextEditingController(text: inp.blend2PricePerKg.toStringAsFixed(2));
    _b2Waste =
        TextEditingController(text: inp.blend2WastePct.toStringAsFixed(1));
    _b2Pct = TextEditingController(text: inp.blend2Pct.toStringAsFixed(1));

    _yarnType = inp.yarnType;
    _priceMode = inp.priceMode;
    _isBlend = inp.isBlend;
  }

  @override
  void dispose() {
    for (final c in [
      _count, _cotton, _elec, _spindleSpeed, _tm, _utilisation,
      _packing, _addPacking, _price, _margin,
      _rfEff, _simplexHank, _simplexSpeed, _simplexTm, _simplexEff,
      _comberNoil, _windingEff, _brWaste, _cardWaste, _yarnWaste,
      _b2Price, _b2Waste, _b2Pct,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  CalculationInput _buildInput() {
    final mill = ref.read(activeMillProvider);
    final count = double.tryParse(_count.text) ?? 94;
    final bracket = mill.bracketFor(count) ??
        ref.read(calculationInputProvider).bracket;

    // Build a bracket with user overrides
    final editedBracket = bracket.copyWith(
      ringFrameEfficiency: (double.tryParse(_rfEff.text) ?? 95) / 100,
      simplexHank: double.tryParse(_simplexHank.text),
      simplexSpeedRpm: double.tryParse(_simplexSpeed.text),
      simplexTM: double.tryParse(_simplexTm.text),
      simplexEfficiency: (double.tryParse(_simplexEff.text) ?? 84) / 100,
      windingEfficiency: (double.tryParse(_windingEff.text) ?? 75) / 100,
    );

    final plies = (_yarnType == YarnType.tfoDoubled) ? 2 : 1;

    return CalculationInput(
      resultantCount: count,
      yarnType: _yarnType,
      plies: plies,
      bracket: editedBracket,
      spindleSpeedRpm: double.tryParse(_spindleSpeed.text) ?? 16500,
      twistMultiplier: double.tryParse(_tm.text) ?? 4.2,
      utilisationPct: double.tryParse(_utilisation.text) ?? 98,
      cottonPricePerCandy: double.tryParse(_cotton.text) ?? 75000,
      isBlend: _isBlend,
      blend1Pct: _isBlend ? (100 - (double.tryParse(_b2Pct.text) ?? 0)) : 100,
      blend2PricePerKg: double.tryParse(_b2Price.text) ?? 0,
      blend2WastePct: double.tryParse(_b2Waste.text) ?? 0,
      blend2Pct: double.tryParse(_b2Pct.text) ?? 0,
      blowRoomWastePct: double.tryParse(_brWaste.text) ?? 5.0,
      cardingWastePct: double.tryParse(_cardWaste.text) ?? 6.65,
      comberNoilPct: double.tryParse(_comberNoil.text) ?? 15.9,
      yarnWastePct: double.tryParse(_yarnWaste.text) ?? 1.09,
      electricityRatePerKwh: double.tryParse(_elec.text) ?? 8.0,
      packingRatePerKg: double.tryParse(_packing.text) ?? 8.0,
      additionalPackingForPlied: double.tryParse(_addPacking.text) ?? 1.0,
      priceMode: _priceMode,
      sellingPricePerKg: double.tryParse(_price.text) ?? 380,
      targetMarginPct: double.tryParse(_margin.text) ?? 10,
    );
  }

  void _onCountChanged(String val) {
    final count = double.tryParse(val);
    if (count == null) return;
    final mill = ref.read(activeMillProvider);
    final bracket = mill.bracketFor(count);
    if (bracket != null) {
      setState(() {
        _rfEff.text = (bracket.ringFrameEfficiency * 100).toStringAsFixed(1);
        _simplexHank.text = bracket.simplexHank.toStringAsFixed(2);
        _simplexSpeed.text = bracket.simplexSpeedRpm.toStringAsFixed(0);
        _simplexTm.text = bracket.simplexTM.toStringAsFixed(2);
        _simplexEff.text = (bracket.simplexEfficiency * 100).toStringAsFixed(1);
        _comberNoil.text = bracket.comberNoilPct.toStringAsFixed(1);
        _windingEff.text = (bracket.windingEfficiency * 100).toStringAsFixed(1);
      });
    }
  }

  void _calculate() {
    final input = _buildInput();
    ref.read(calculationInputProvider.notifier).update(input);
    final resultAsync = ref.read(calculationResultProvider);
    resultAsync.when(
      data: (result) => context.push('/results', extra: result),
      error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Calculation error: $e'),
          backgroundColor: AppTheme.danger,
        ),
      ),
      loading: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Calculation'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Yarn Type ──────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'YARN TYPE'),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<YarnType>(
                      initialValue: _yarnType,
                      decoration: const InputDecoration(labelText: 'Yarn Type'),
                      items: YarnType.values.map((t) {
                        final available = t.isAvailable;
                        return DropdownMenuItem(
                          value: t,
                          enabled: available,
                          child: Text(
                            available ? t.label : '${t.label} (coming soon)',
                            style: TextStyle(
                              color: available
                                  ? AppTheme.textPrimary
                                  : AppTheme.textSecondary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (t) {
                        if (t != null && t.isAvailable) {
                          setState(() => _yarnType = t);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    LabelField(
                      label: 'Resultant Count (Ne)',
                      unit: 'Ne',
                      controller: _count,
                      onChanged: _onCountChanged,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Material ───────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'MATERIAL'),
                    const SizedBox(height: 12),
                    LabelField(
                      label: 'Cotton Price',
                      unit: '₹/candy',
                      controller: _cotton,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Blend',
                            style: TextStyle(
                                fontSize: 14, color: AppTheme.textPrimary)),
                        const Spacer(),
                        Switch.adaptive(
                          value: _isBlend,
                          onChanged: (v) => setState(() => _isBlend = v),
                          activeThumbColor: AppTheme.primary,
                        ),
                      ],
                    ),
                    if (_isBlend) ...[
                      const SizedBox(height: 8),
                      LabelField(
                        label: 'Blend 2 Price',
                        unit: '₹/kg',
                        controller: _b2Price,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: LabelField(
                              label: 'Blend 2 %',
                              unit: '%',
                              controller: _b2Pct,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: LabelField(
                              label: 'Blend 2 Waste %',
                              unit: '%',
                              controller: _b2Waste,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Machine Params (auto-filled, editable) ─────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                            child: SectionHeader(title: 'MACHINE PARAMETERS')),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryLight,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Auto-filled',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: LabelField(
                            label: 'Spindle Speed',
                            unit: 'RPM',
                            controller: _spindleSpeed,
                            isInteger: true,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LabelField(
                            label: 'Twist Multiplier',
                            controller: _tm,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LabelField(
                            label: 'Utilisation',
                            unit: '%',
                            controller: _utilisation,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LabelField(
                            label: 'RF Efficiency',
                            unit: '%',
                            controller: _rfEff,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LabelField(
                            label: 'Simplex Hank',
                            controller: _simplexHank,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LabelField(
                            label: 'Simplex Speed',
                            unit: 'RPM',
                            controller: _simplexSpeed,
                            isInteger: true,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LabelField(
                            label: 'Simplex TM',
                            controller: _simplexTm,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LabelField(
                            label: 'Simplex Eff.',
                            unit: '%',
                            controller: _simplexEff,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LabelField(
                            label: 'Comber Noil',
                            unit: '%',
                            controller: _comberNoil,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LabelField(
                            label: 'Winding Eff.',
                            unit: '%',
                            controller: _windingEff,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Waste rates ────────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'WASTE RATES'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: LabelField(
                            label: 'Blow Room Waste',
                            unit: '%',
                            controller: _brWaste,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LabelField(
                            label: 'Carding Waste',
                            unit: '%',
                            controller: _cardWaste,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: LabelField(
                            label: 'Yarn Waste',
                            unit: '%',
                            controller: _yarnWaste,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(child: SizedBox()),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Energy & Packing ───────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'ENERGY & PACKING'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: LabelField(
                            label: 'Electricity Rate',
                            unit: '₹/kWh',
                            controller: _elec,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: LabelField(
                            label: 'Packing Rate',
                            unit: '₹/kg',
                            controller: _packing,
                          ),
                        ),
                      ],
                    ),
                    if (_yarnType == YarnType.tfoDoubled) ...[
                      const SizedBox(height: 8),
                      LabelField(
                        label: 'Additional Packing (TFO)',
                        unit: '₹/kg',
                        controller: _addPacking,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Price / Margin ─────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'PRICE / MARGIN'),
                    const SizedBox(height: 12),
                    // Toggle
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.divider),
                      ),
                      child: Row(
                        children: [
                          _PriceModeTab(
                            label: 'Enter Price',
                            active: _priceMode == 'price',
                            onTap: () =>
                                setState(() => _priceMode = 'price'),
                          ),
                          _PriceModeTab(
                            label: 'Target Margin',
                            active: _priceMode == 'margin',
                            onTap: () =>
                                setState(() => _priceMode = 'margin'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_priceMode == 'price')
                      LabelField(
                        label: 'Selling Price',
                        unit: '₹/kg',
                        controller: _price,
                      )
                    else
                      LabelField(
                        label: 'Target Margin',
                        unit: '%',
                        controller: _margin,
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // ── Calculate button ───────────────────────────────────────────
            ElevatedButton.icon(
              onPressed: _calculate,
              icon: const Icon(Icons.calculate),
              label: const Text('Calculate Cost'),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _PriceModeTab extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _PriceModeTab(
      {required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: active ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(7),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: active ? Colors.white : AppTheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
