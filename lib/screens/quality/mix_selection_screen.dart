import 'package:flutter/material.dart';
import '../../quality/qd_engine.dart';
import '../../theme/app_theme.dart';
import '_qd_widgets.dart';

// Default cotton set from the spec
const _defaultCottons = [
  MixCotton(name: 'S-6', uhmlMm: 29, strengthGtex: 30, mic: 4.3, ui: 80, fibreElongation: 5, priceRsPerCandy: 33000, yarnRealisationPct: 71),
  MixCotton(name: 'MCU-5', uhmlMm: 31.5, strengthGtex: 32, mic: 4.0, ui: 81, fibreElongation: 6, priceRsPerCandy: 33500, yarnRealisationPct: 69),
  MixCotton(name: 'DCH', uhmlMm: 34, strengthGtex: 34, mic: 3.8, ui: 81.5, fibreElongation: 6.5, priceRsPerCandy: 42000, yarnRealisationPct: 67),
  MixCotton(name: 'Pima', uhmlMm: 35, strengthGtex: 40, mic: 4.1, ui: 82, fibreElongation: 7, priceRsPerCandy: 85000, yarnRealisationPct: 75),
  MixCotton(name: 'Giza 86', uhmlMm: 32, strengthGtex: 39, mic: 4.2, ui: 81, fibreElongation: 6.5, priceRsPerCandy: 78000, yarnRealisationPct: 71),
  MixCotton(name: 'Giza 88', uhmlMm: 35, strengthGtex: 40, mic: 4.0, ui: 82, fibreElongation: 7, priceRsPerCandy: 84000, yarnRealisationPct: 72),
];

class MixSelectionScreen extends StatefulWidget {
  const MixSelectionScreen({super.key});

  @override
  State<MixSelectionScreen> createState() => _MixSelectionScreenState();
}

class _MixSelectionScreenState extends State<MixSelectionScreen>
    with TickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mix Selection'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'From Available Cotton'),
            Tab(text: 'Recommendation'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _FromAvailableCotton(),
          _RecommendationMix(),
        ],
      ),
    );
  }
}

// ── Tab 1: From available cotton ─────────────────────────────────────────────

class _FromAvailableCotton extends StatefulWidget {
  const _FromAvailableCotton();

  @override
  State<_FromAvailableCotton> createState() => _FromAvailableCottonState();
}

class _FromAvailableCottonState extends State<_FromAvailableCotton> {
  final _count = TextEditingController(text: '60');
  final _tm = TextEditingController(text: '4');
  final _targetStrength = TextEditingController(text: '20');

  // ignore: prefer_final_fields
  List<_EditableCotton> _cottons = _defaultCottons.map(_EditableCotton.from).toList();
  // ignore: prefer_final_fields
  List<bool> _selected = List.filled(_defaultCottons.length, true);
  MixResult? _result;
  List<double> _perCottonStrengths = [];

  void _solve() {
    final count = double.tryParse(_count.text) ?? 60;
    final tm = double.tryParse(_tm.text) ?? 4;
    final target = double.tryParse(_targetStrength.text) ?? 20;
    final chosen = <MixCotton>[];
    for (int i = 0; i < _cottons.length; i++) {
      if (_selected[i]) chosen.add(_cottons[i].toMixCotton());
    }
    if (chosen.isEmpty) return;
    setState(() {
      _perCottonStrengths = _cottons.map((c) => cottonYarnStrength(c.toMixCotton(), count, tm)).toList();
      _result = optimiseMix(
        cottons: chosen,
        count: count,
        tm: tm,
        targetStrength: target,
      );
    });
  }

  void _addCotton() {
    setState(() {
      _cottons.add(_EditableCotton());
      _selected.add(true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QdInfoCard(
            'Enter your available cottons, select which to include, '
            'set target count and strength, then run the optimiser.',
          ),
          const SizedBox(height: 14),
          const QdSectionLabel('Target Yarn'),
          Row(children: [
            Expanded(child: QdField('Count (Ne)', _count, '60')),
            const SizedBox(width: 10),
            Expanded(child: QdField('Twist Multiplier (TM)', _tm, '4')),
          ]),
          const SizedBox(height: 10),
          QdField('Target Strength (RKM)', _targetStrength, '20'),
          const SizedBox(height: 14),
          Row(
            children: [
              const QdSectionLabel('Cotton Table'),
              const Spacer(),
              TextButton.icon(
                onPressed: _addCotton,
                icon: const Icon(Icons.add, size: 16),
                label: const Text('Add Cotton'),
              ),
            ],
          ),
          ..._cottons.asMap().entries.map((e) => _CottonRow(
            cotton: e.value,
            selected: _selected[e.key],
            onToggle: (v) => setState(() => _selected[e.key] = v),
            onDelete: () => setState(() {
              _cottons.removeAt(e.key);
              _selected.removeAt(e.key);
            }),
            predictedStrength: _perCottonStrengths.isNotEmpty ? _perCottonStrengths[e.key] : null,
          )),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _solve,
              child: const Text('Optimise Blend'),
            ),
          ),
          if (_result != null) ...[
            const SizedBox(height: 20),
            const QdSectionLabel('Optimised Blend'),
            QdResultCard(children: [
              QdResultRow('Expected Yarn Strength', '${_result!.blendStrength.toStringAsFixed(2)} RKM', highlight: true),
              QdResultRow('Blend Cost', '₹${_result!.blendCostPerCandy.toStringAsFixed(0)}/candy', highlight: true),
              const Divider(height: 12),
              ..._cottons.asMap().entries.where((e) => _selected[e.key]).map((e) {
                final selectedIdx = _cottons.asMap().entries
                    .where((ee) => _selected[ee.key])
                    .toList()
                    .indexWhere((ee) => ee.key == e.key);
                if (selectedIdx >= 0 && selectedIdx < _result!.ratios.length) {
                  return QdResultRow(
                    e.value.name.isEmpty ? 'Cotton ${e.key + 1}' : e.value.name,
                    '${_result!.ratios[selectedIdx].toStringAsFixed(1)}%',
                  );
                }
                return const SizedBox.shrink();
              }),
            ]),
          ],
        ],
      ),
    );
  }
}

class _EditableCotton {
  String name;
  double uhmlMm, strengthGtex, mic, ui, fibreElongation, priceRsPerCandy, yarnRealisationPct;

  _EditableCotton({
    this.name = '',
    this.uhmlMm = 30,
    this.strengthGtex = 28,
    this.mic = 4.2,
    this.ui = 81,
    this.fibreElongation = 6,
    this.priceRsPerCandy = 35000,
    this.yarnRealisationPct = 70,
  });

  static _EditableCotton from(MixCotton c) => _EditableCotton(
    name: c.name,
    uhmlMm: c.uhmlMm,
    strengthGtex: c.strengthGtex,
    mic: c.mic,
    ui: c.ui,
    fibreElongation: c.fibreElongation,
    priceRsPerCandy: c.priceRsPerCandy,
    yarnRealisationPct: c.yarnRealisationPct,
  );

  MixCotton toMixCotton() => MixCotton(
    name: name,
    uhmlMm: uhmlMm,
    strengthGtex: strengthGtex,
    mic: mic,
    ui: ui,
    fibreElongation: fibreElongation,
    priceRsPerCandy: priceRsPerCandy,
    yarnRealisationPct: yarnRealisationPct,
  );
}

class _CottonRow extends StatelessWidget {
  final _EditableCotton cotton;
  final bool selected;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;
  final double? predictedStrength;

  const _CottonRow({
    required this.cotton,
    required this.selected,
    required this.onToggle,
    required this.onDelete,
    this.predictedStrength,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            Row(
              children: [
                Checkbox(value: selected, onChanged: (v) => onToggle(v ?? false)),
                Expanded(
                  child: TextFormField(
                    initialValue: cotton.name,
                    decoration: const InputDecoration(labelText: 'Name', isDense: true),
                    onChanged: (v) => cotton.name = v,
                  ),
                ),
                IconButton(onPressed: onDelete, icon: const Icon(Icons.delete_outline, size: 18)),
              ],
            ),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: _miniField('UHML (mm)', cotton.uhmlMm.toString(), (v) => cotton.uhmlMm = double.tryParse(v) ?? cotton.uhmlMm)),
              const SizedBox(width: 6),
              Expanded(child: _miniField('Str (g/tex)', cotton.strengthGtex.toString(), (v) => cotton.strengthGtex = double.tryParse(v) ?? cotton.strengthGtex)),
              const SizedBox(width: 6),
              Expanded(child: _miniField('Mic', cotton.mic.toString(), (v) => cotton.mic = double.tryParse(v) ?? cotton.mic)),
            ]),
            const SizedBox(height: 6),
            Row(children: [
              Expanded(child: _miniField('UI %', cotton.ui.toString(), (v) => cotton.ui = double.tryParse(v) ?? cotton.ui)),
              const SizedBox(width: 6),
              Expanded(child: _miniField('Elong %', cotton.fibreElongation.toString(), (v) => cotton.fibreElongation = double.tryParse(v) ?? cotton.fibreElongation)),
              const SizedBox(width: 6),
              Expanded(child: _miniField('Price ₹/candy', cotton.priceRsPerCandy.toString(), (v) => cotton.priceRsPerCandy = double.tryParse(v) ?? cotton.priceRsPerCandy)),
            ]),
            if (predictedStrength != null)
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Predicted strength: ${predictedStrength!.toStringAsFixed(2)} RKM',
                  style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _miniField(String label, String init, ValueChanged<String> onChange) {
    return TextFormField(
      initialValue: init,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, isDense: true),
      style: const TextStyle(fontSize: 12),
      onChanged: onChange,
    );
  }
}

// ── Tab 2: Recommendation from built-in DB ───────────────────────────────────

class _RecommendationMix extends StatefulWidget {
  const _RecommendationMix();

  @override
  State<_RecommendationMix> createState() => _RecommendationMixState();
}

class _RecommendationMixState extends State<_RecommendationMix> {
  final _count = TextEditingController(text: '60');
  final _tm = TextEditingController(text: '4');
  final _targetStrength = TextEditingController(text: '20');
  int _filter = 0; // 0=All, 1=Indian, 2=Imported

  MixResult? _result;
  List<double> _perStrengths = [];
  List<MixCotton> _usedCottons = [];

  void _solve() {
    final count = double.tryParse(_count.text) ?? 60;
    final tm = double.tryParse(_tm.text) ?? 4;
    final target = double.tryParse(_targetStrength.text) ?? 20;

    List<MixCotton> pool = _defaultCottons;
    if (_filter == 1) {
      pool = _defaultCottons.where((c) => !['Pima', 'Giza 86', 'Giza 88'].contains(c.name)).toList();
    } else if (_filter == 2) {
      pool = _defaultCottons.where((c) => ['Pima', 'Giza 86', 'Giza 88'].contains(c.name)).toList();
    }

    setState(() {
      _usedCottons = pool;
      _perStrengths = pool.map((c) => cottonYarnStrength(c, count, tm)).toList();
      _result = optimiseMix(cottons: pool, count: count, tm: tm, targetStrength: target);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const QdInfoCard(
            'Uses the built-in cotton database to recommend a blend. '
            'Filter by cotton origin and set your target.',
          ),
          const SizedBox(height: 14),
          const QdSectionLabel('Target Yarn'),
          Row(children: [
            Expanded(child: QdField('Count (Ne)', _count, '60')),
            const SizedBox(width: 10),
            Expanded(child: QdField('Twist Multiplier (TM)', _tm, '4')),
          ]),
          const SizedBox(height: 10),
          QdField('Target Strength (RKM)', _targetStrength, '20'),
          const SizedBox(height: 12),
          const QdSectionLabel('Cotton Type Filter'),
          Wrap(spacing: 8, children: [
            ChoiceChip(label: const Text('All'), selected: _filter == 0, onSelected: (_) => setState(() => _filter = 0), selectedColor: AppTheme.primaryLight),
            ChoiceChip(label: const Text('Indian Only'), selected: _filter == 1, onSelected: (_) => setState(() => _filter = 1), selectedColor: AppTheme.primaryLight),
            ChoiceChip(label: const Text('Imported Only'), selected: _filter == 2, onSelected: (_) => setState(() => _filter = 2), selectedColor: AppTheme.primaryLight),
          ]),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _solve,
              child: const Text('Get Recommendation'),
            ),
          ),
          if (_perStrengths.isNotEmpty) ...[
            const SizedBox(height: 16),
            const QdSectionLabel('Per-Cotton Predicted Strength'),
            QdResultCard(children: [
              ..._usedCottons.asMap().entries.map((e) =>
                QdResultRow(e.value.name, '${_perStrengths[e.key].toStringAsFixed(2)} RKM')
              ),
            ]),
          ],
          if (_result != null) ...[
            const SizedBox(height: 12),
            const QdSectionLabel('Recommended Blend'),
            QdResultCard(children: [
              QdResultRow('Expected Yarn Strength', '${_result!.blendStrength.toStringAsFixed(2)} RKM', highlight: true),
              QdResultRow('Blend Cost', '₹${_result!.blendCostPerCandy.toStringAsFixed(0)}/candy', highlight: true),
              const Divider(height: 12),
              ..._usedCottons.asMap().entries.map((e) =>
                QdResultRow(e.value.name, '${_result!.ratios[e.key].toStringAsFixed(1)}%')
              ),
            ]),
          ],
        ],
      ),
    );
  }
}
