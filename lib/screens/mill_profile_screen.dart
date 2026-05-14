import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../models/mill_profile.dart';
import '../providers/mill_profile_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/label_field.dart';

const _uuid = Uuid();

// ── Profile list screen ────────────────────────────────────────────────────

class MillProfileScreen extends ConsumerWidget {
  const MillProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profiles = ref.watch(millProfilesProvider);
    final active = ref.watch(activeMillProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mill Profiles'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            onPressed: () => _createNew(context, ref),
            icon: const Icon(Icons.add),
            tooltip: 'New profile',
          ),
        ],
      ),
      body: profiles.isEmpty
          ? const Center(child: Text('No mill profiles yet.'))
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: profiles.length,
              separatorBuilder: (context, index) => const SizedBox(height: 8),
              itemBuilder: (ctx, i) {
                final mill = profiles[i];
                final isActive = mill.id == active.id;
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: isActive
                          ? AppTheme.primary
                          : AppTheme.primaryLight,
                      child: Icon(
                        Icons.factory,
                        color: isActive ? Colors.white : AppTheme.primary,
                        size: 18,
                      ),
                    ),
                    title: Text(mill.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      '${mill.totalSpindles} spindles · '
                      '${mill.ringFrameCount} frames · '
                      '${mill.cards} cards',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryLight,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'ACTIVE',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary,
                              ),
                            ),
                          ),
                        IconButton(
                          onPressed: () =>
                              context.push('/profiles/edit/${mill.id}'),
                          icon: const Icon(Icons.edit_outlined, size: 20),
                          color: AppTheme.textSecondary,
                        ),
                        if (!isActive)
                          IconButton(
                            onPressed: () =>
                                _confirmDelete(context, ref, mill),
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: AppTheme.danger,
                          ),
                      ],
                    ),
                    onTap: () {
                      ref.read(activeMillProvider.notifier).select(mill);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Active mill: ${mill.name}'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  void _createNew(BuildContext context, WidgetRef ref) {
    final newMill = MillProfile.rst2.copyWith(
      id: _uuid.v4(),
      name: 'New Mill',
    );
    ref.read(millProfilesProvider.notifier).save(newMill);
    context.push('/profiles/edit/${newMill.id}');
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, MillProfile mill) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Profile'),
        content: Text('Delete "${mill.name}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref.read(millProfilesProvider.notifier).delete(mill.id);
              Navigator.pop(ctx);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ── Profile edit screen ────────────────────────────────────────────────────

class MillProfileEditScreen extends ConsumerStatefulWidget {
  final String profileId;

  const MillProfileEditScreen({super.key, required this.profileId});

  @override
  ConsumerState<MillProfileEditScreen> createState() =>
      _MillProfileEditScreenState();
}

class _MillProfileEditScreenState
    extends ConsumerState<MillProfileEditScreen> {
  late MillProfile _mill;
  late TextEditingController _name;

  // Machine controllers
  late TextEditingController _rfCount, _rfSpindles;
  late TextEditingController _simplexMachines, _simplexSpl;
  late TextEditingController _finDrawMachines, _finDrawDel;
  late TextEditingController _preComberMachines, _preComberDel;
  late TextEditingController _combers, _lapFormers, _cards, _blowRoomLines;
  late TextEditingController _windMachines, _windDrums;
  late TextEditingController _tfoSpindles, _tfoKw;

  // Financial controllers
  late TextEditingController _wc, _dep, _oh, _intRate;
  late TextEditingController _staffCount, _staffSalary, _wageRate, _indirect;

  // Waste rate controllers
  late TextEditingController _brWaste, _cardWaste, _yarnWaste;
  late TextEditingController _brRate, _cardRate, _noilRate, _yarnRate;

  @override
  void initState() {
    super.initState();
    final profiles = ref.read(millProfilesProvider);
    _mill = profiles.firstWhere((p) => p.id == widget.profileId,
        orElse: () => MillProfile.rst2);
    _initControllers();
  }

  void _initControllers() {
    final m = _mill;
    _name = TextEditingController(text: m.name);
    _rfCount = TextEditingController(text: m.ringFrameCount.toString());
    _rfSpindles = TextEditingController(text: m.spindlesPerFrame.toString());
    _simplexMachines =
        TextEditingController(text: m.simplexMachines.toString());
    _simplexSpl = TextEditingController(
        text: m.simplexSpindlesPerMachine.toString());
    _finDrawMachines =
        TextEditingController(text: m.finDrawingMachines.toString());
    _finDrawDel = TextEditingController(
        text: m.finDrawingDeliveriesPerMachine.toString());
    _preComberMachines =
        TextEditingController(text: m.preComberDrawingMachines.toString());
    _preComberDel = TextEditingController(
        text: m.preComberDeliveriesPerMachine.toString());
    _combers = TextEditingController(text: m.combers.toString());
    _lapFormers = TextEditingController(text: m.lapFormers.toString());
    _cards = TextEditingController(text: m.cards.toString());
    _blowRoomLines = TextEditingController(text: m.blowRoomLines.toString());
    _windMachines =
        TextEditingController(text: m.windingMachines.toString());
    _windDrums =
        TextEditingController(text: m.drumsPerWindingMachine.toString());
    _tfoSpindles = TextEditingController(text: m.tfoSpindles.toString());
    _tfoKw = TextEditingController(text: m.tfoInstalledKw.toString());

    _wc = TextEditingController(
        text: m.workingCapitalLakhs.toStringAsFixed(0));
    _dep = TextEditingController(
        text: m.annualDepreciationLakhs.toStringAsFixed(0));
    _oh = TextEditingController(
        text: m.annualOverheadsLakhs.toStringAsFixed(0));
    _intRate = TextEditingController(
        text: m.interestRatePct.toStringAsFixed(1));
    _staffCount = TextEditingController(text: m.staffCount.toString());
    _staffSalary = TextEditingController(
        text: m.monthlyStaffSalary.toStringAsFixed(0));
    _wageRate =
        TextEditingController(text: m.dailyWageRate.toStringAsFixed(0));
    _indirect = TextEditingController(text: m.indirectStaff.toString());

    _brWaste =
        TextEditingController(text: m.blowRoomWastePct.toStringAsFixed(2));
    _cardWaste =
        TextEditingController(text: m.cardingWastePct.toStringAsFixed(2));
    _yarnWaste =
        TextEditingController(text: m.yarnWastePct.toStringAsFixed(2));
    _brRate =
        TextEditingController(text: m.blowRoomWasteRate.toStringAsFixed(0));
    _cardRate =
        TextEditingController(text: m.cardingWasteRate.toStringAsFixed(0));
    _noilRate =
        TextEditingController(text: m.comberNoilRate.toStringAsFixed(0));
    _yarnRate =
        TextEditingController(text: m.yarnWasteRate.toStringAsFixed(0));
  }

  @override
  void dispose() {
    for (final c in [
      _name, _rfCount, _rfSpindles, _simplexMachines, _simplexSpl,
      _finDrawMachines, _finDrawDel, _preComberMachines, _preComberDel,
      _combers, _lapFormers, _cards, _blowRoomLines, _windMachines, _windDrums,
      _tfoSpindles, _tfoKw, _wc, _dep, _oh, _intRate, _staffCount,
      _staffSalary, _wageRate, _indirect, _brWaste, _cardWaste, _yarnWaste,
      _brRate, _cardRate, _noilRate, _yarnRate,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  MillProfile _buildProfile() {
    return _mill.copyWith(
      name: _name.text.trim().isEmpty ? 'Unnamed Mill' : _name.text.trim(),
      ringFrameCount: int.tryParse(_rfCount.text) ?? _mill.ringFrameCount,
      spindlesPerFrame: int.tryParse(_rfSpindles.text) ?? _mill.spindlesPerFrame,
      simplexMachines:
          int.tryParse(_simplexMachines.text) ?? _mill.simplexMachines,
      simplexSpindlesPerMachine:
          int.tryParse(_simplexSpl.text) ?? _mill.simplexSpindlesPerMachine,
      finDrawingMachines:
          int.tryParse(_finDrawMachines.text) ?? _mill.finDrawingMachines,
      finDrawingDeliveriesPerMachine:
          int.tryParse(_finDrawDel.text) ??
              _mill.finDrawingDeliveriesPerMachine,
      preComberDrawingMachines:
          int.tryParse(_preComberMachines.text) ??
              _mill.preComberDrawingMachines,
      preComberDeliveriesPerMachine:
          int.tryParse(_preComberDel.text) ??
              _mill.preComberDeliveriesPerMachine,
      combers: int.tryParse(_combers.text) ?? _mill.combers,
      lapFormers: int.tryParse(_lapFormers.text) ?? _mill.lapFormers,
      cards: int.tryParse(_cards.text) ?? _mill.cards,
      blowRoomLines: int.tryParse(_blowRoomLines.text) ?? _mill.blowRoomLines,
      windingMachines:
          int.tryParse(_windMachines.text) ?? _mill.windingMachines,
      drumsPerWindingMachine:
          int.tryParse(_windDrums.text) ?? _mill.drumsPerWindingMachine,
      tfoSpindles: int.tryParse(_tfoSpindles.text) ?? _mill.tfoSpindles,
      tfoInstalledKw: double.tryParse(_tfoKw.text) ?? _mill.tfoInstalledKw,
      workingCapitalLakhs:
          double.tryParse(_wc.text) ?? _mill.workingCapitalLakhs,
      annualDepreciationLakhs:
          double.tryParse(_dep.text) ?? _mill.annualDepreciationLakhs,
      annualOverheadsLakhs:
          double.tryParse(_oh.text) ?? _mill.annualOverheadsLakhs,
      interestRatePct:
          double.tryParse(_intRate.text) ?? _mill.interestRatePct,
      staffCount: int.tryParse(_staffCount.text) ?? _mill.staffCount,
      monthlyStaffSalary:
          double.tryParse(_staffSalary.text) ?? _mill.monthlyStaffSalary,
      dailyWageRate: double.tryParse(_wageRate.text) ?? _mill.dailyWageRate,
      indirectStaff: int.tryParse(_indirect.text) ?? _mill.indirectStaff,
      blowRoomWastePct:
          double.tryParse(_brWaste.text) ?? _mill.blowRoomWastePct,
      cardingWastePct:
          double.tryParse(_cardWaste.text) ?? _mill.cardingWastePct,
      yarnWastePct: double.tryParse(_yarnWaste.text) ?? _mill.yarnWastePct,
      blowRoomWasteRate:
          double.tryParse(_brRate.text) ?? _mill.blowRoomWasteRate,
      cardingWasteRate:
          double.tryParse(_cardRate.text) ?? _mill.cardingWasteRate,
      comberNoilRate: double.tryParse(_noilRate.text) ?? _mill.comberNoilRate,
      yarnWasteRate: double.tryParse(_yarnRate.text) ?? _mill.yarnWasteRate,
    );
  }

  Future<void> _save() async {
    final updated = _buildProfile();
    await ref.read(millProfilesProvider.notifier).save(updated);
    // If this is the active mill, update active too
    final active = ref.read(activeMillProvider);
    if (active.id == updated.id) {
      await ref.read(activeMillProvider.notifier).select(updated);
    }
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mill profile saved.')),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Mill Profile'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save',
                style: TextStyle(
                    color: AppTheme.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: LabelField(
                    label: 'Mill Name', controller: _name),
              ),
            ),
            const SizedBox(height: 12),

            // Machines
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'RING FRAME'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: LabelField(
                              label: 'Frames',
                              controller: _rfCount,
                              isInteger: true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: LabelField(
                              label: 'Spindles/frame',
                              controller: _rfSpindles,
                              isInteger: true)),
                    ]),
                    const SizedBox(height: 16),
                    const SectionHeader(title: 'SIMPLEX'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: LabelField(
                              label: 'Machines',
                              controller: _simplexMachines,
                              isInteger: true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: LabelField(
                              label: 'Spindles/machine',
                              controller: _simplexSpl,
                              isInteger: true)),
                    ]),
                    const SizedBox(height: 16),
                    const SectionHeader(title: 'DRAWING'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: LabelField(
                              label: 'Fin. Draw Machines',
                              controller: _finDrawMachines,
                              isInteger: true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: LabelField(
                              label: 'Del/machine',
                              controller: _finDrawDel,
                              isInteger: true)),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: LabelField(
                              label: 'Pre-Comber Machines',
                              controller: _preComberMachines,
                              isInteger: true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: LabelField(
                              label: 'Del/machine',
                              controller: _preComberDel,
                              isInteger: true)),
                    ]),
                    const SizedBox(height: 16),
                    const SectionHeader(title: 'COMBER, CARDS & WINDING'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: LabelField(
                              label: 'Combers',
                              controller: _combers,
                              isInteger: true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: LabelField(
                              label: 'Lap Formers',
                              controller: _lapFormers,
                              isInteger: true)),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: LabelField(
                              label: 'Cards',
                              controller: _cards,
                              isInteger: true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: LabelField(
                              label: 'Blow Room Lines',
                              controller: _blowRoomLines,
                              isInteger: true)),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: LabelField(
                              label: 'Winding Machines',
                              controller: _windMachines,
                              isInteger: true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: LabelField(
                              label: 'Drums/machine',
                              controller: _windDrums,
                              isInteger: true)),
                    ]),
                    const SizedBox(height: 16),
                    const SectionHeader(title: 'TFO (for doubled yarn)'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: LabelField(
                              label: 'TFO Spindles',
                              controller: _tfoSpindles,
                              isInteger: true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: LabelField(
                              label: 'TFO Installed kW',
                              controller: _tfoKw)),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Financial
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'FINANCIAL (₹ LAKHS/YEAR)'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: LabelField(
                              label: 'Working Capital',
                              unit: 'L',
                              controller: _wc)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: LabelField(
                              label: 'Interest Rate',
                              unit: '%',
                              controller: _intRate)),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: LabelField(
                              label: 'Depreciation',
                              unit: 'L/yr',
                              controller: _dep)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: LabelField(
                              label: 'Fixed Overheads',
                              unit: 'L/yr',
                              controller: _oh)),
                    ]),
                    const SizedBox(height: 16),
                    const SectionHeader(title: 'STAFF & WAGES'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: LabelField(
                              label: 'Staff Count',
                              controller: _staffCount,
                              isInteger: true)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: LabelField(
                              label: 'Monthly Salary',
                              unit: '₹',
                              controller: _staffSalary)),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: LabelField(
                              label: 'Daily Wage Rate',
                              unit: '₹/day',
                              controller: _wageRate)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: LabelField(
                              label: 'Indirect Staff',
                              controller: _indirect,
                              isInteger: true)),
                    ]),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Waste
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SectionHeader(title: 'WASTE RATES (%) & SALE RATES (₹/KG)'),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                          child: LabelField(
                              label: 'Blow Room Waste %',
                              unit: '%',
                              controller: _brWaste)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: LabelField(
                              label: 'Blow Room Rate',
                              unit: '₹/kg',
                              controller: _brRate)),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: LabelField(
                              label: 'Carding Waste %',
                              unit: '%',
                              controller: _cardWaste)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: LabelField(
                              label: 'Carding Waste Rate',
                              unit: '₹/kg',
                              controller: _cardRate)),
                    ]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Expanded(
                          child: LabelField(
                              label: 'Yarn Waste %',
                              unit: '%',
                              controller: _yarnWaste)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: LabelField(
                              label: 'Yarn Waste Rate',
                              unit: '₹/kg',
                              controller: _yarnRate)),
                    ]),
                    const SizedBox(height: 8),
                    LabelField(
                      label: 'Comber Noil Sale Rate',
                      unit: '₹/kg',
                      controller: _noilRate,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _save,
              child: const Text('Save Mill Profile'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
