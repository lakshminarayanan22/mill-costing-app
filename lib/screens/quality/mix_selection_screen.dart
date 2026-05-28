import 'package:fl_chart/fl_chart.dart';
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
  String _lpFormulation = '';
  List<MixCotton> _lastChosen = [];

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
      _perCottonStrengths = _cottons
          .map((c) => cottonYarnStrength(c.toMixCotton(), count, tm))
          .toList();
      _lastChosen = chosen;
      _result = optimiseMix(
        cottons: chosen,
        count: count,
        tm: tm,
        targetStrength: target,
      );
      _lpFormulation = blendLpFormulation(
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

  void _showLp(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('LP Formulation (Simplex)'),
        content: SingleChildScrollView(
          child: Text(
            _lpFormulation,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEDE9FE),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.functions, size: 16, color: Color(0xFF6D28D9)),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Solved by Big-M Simplex (Linear Programming). '
                    'Finds the minimum-cost blend that exactly meets the strength target. '
                    'Tap "Show LP" to see the full formulation.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF6D28D9)),
                  ),
                ),
              ],
            ),
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
              const Expanded(child: QdSectionLabel('Cotton Table')),
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
                predictedStrength: _perCottonStrengths.isNotEmpty
                    ? _perCottonStrengths[e.key]
                    : null,
              )),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _solve,
                child: const Text('Optimise Blend'),
              ),
            ),
            if (_lpFormulation.isNotEmpty) ...[
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => _showLp(context),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(80, 48),
                  side: const BorderSide(color: Color(0xFF6D28D9)),
                  foregroundColor: const Color(0xFF6D28D9),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Show LP'),
              ),
            ],
          ]),
          if (_result != null) ...[
            const SizedBox(height: 16),
            if (!_result!.targetMet)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFE02424)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'LP is infeasible: no blend can meet the target strength. '
                        'Showing the strongest achievable blend instead.',
                        style: TextStyle(fontSize: 12, color: Color(0xFFE02424)),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 10),
            const QdSectionLabel('Optimal Blend (Simplex Solution)'),
            QdResultCard(children: [
              QdResultRow(
                'Blend Strength',
                '${_result!.blendStrength.toStringAsFixed(3)} RKM',
                highlight: true,
              ),
              QdResultRow(
                'Minimum Cost',
                '₹${_result!.blendCostPerCandy.toStringAsFixed(0)}/candy  '
                    '(₹${(_result!.blendCostPerCandy / 356).toStringAsFixed(1)}/kg)',
                highlight: true,
              ),
              const Divider(height: 12),
              ..._lastChosen.asMap().entries.map(
                    (e) => QdResultRow(
                      e.value.name.isEmpty ? 'Cotton ${e.key + 1}' : e.value.name,
                      '${_result!.ratios[e.key].toStringAsFixed(2)}%',
                    ),
                  ),
            ]),
            const SizedBox(height: 16),
            _BlendDonut(
              names: _lastChosen.map((c) => c.name.isEmpty ? '?' : c.name).toList(),
              ratios: _result!.ratios,
            ),
            const SizedBox(height: 16),
            _StrengthBars(
              names: _lastChosen.map((c) => c.name.isEmpty ? '?' : c.name).toList(),
              strengths: List.generate(
                _lastChosen.length,
                (i) => cottonYarnStrength(
                  _lastChosen[i],
                  double.tryParse(_count.text) ?? 60,
                  double.tryParse(_tm.text) ?? 4,
                ),
              ),
              target: double.tryParse(_targetStrength.text) ?? 20,
            ),
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
            if (!_result!.targetMet)
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDE8E8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, size: 16, color: Color(0xFFE02424)),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'LP infeasible: no blend in this set meets the target strength.',
                        style: TextStyle(fontSize: 12, color: Color(0xFFE02424)),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            const QdSectionLabel('Optimal Blend (Simplex Solution)'),
            QdResultCard(children: [
              QdResultRow(
                'Blend Strength',
                '${_result!.blendStrength.toStringAsFixed(3)} RKM',
                highlight: true,
              ),
              QdResultRow(
                'Minimum Cost',
                '₹${_result!.blendCostPerCandy.toStringAsFixed(0)}/candy  '
                    '(₹${(_result!.blendCostPerCandy / 356).toStringAsFixed(1)}/kg)',
                highlight: true,
              ),
              const Divider(height: 12),
              ..._usedCottons.asMap().entries.map(
                    (e) => QdResultRow(
                      e.value.name,
                      '${_result!.ratios[e.key].toStringAsFixed(2)}%',
                    ),
                  ),
            ]),
            const SizedBox(height: 16),
            _BlendDonut(
              names: _usedCottons.map((c) => c.name).toList(),
              ratios: _result!.ratios,
            ),
            const SizedBox(height: 16),
            _StrengthBars(
              names: _usedCottons.map((c) => c.name).toList(),
              strengths: _perStrengths,
              target: double.tryParse(_targetStrength.text) ?? 20,
            ),
          ],
        ],
      ),
    );
  }
}

// ── Blend donut chart ─────────────────────────────────────────────────────────

class _BlendDonut extends StatefulWidget {
  final List<String> names;
  final List<double> ratios;

  const _BlendDonut({required this.names, required this.ratios});

  @override
  State<_BlendDonut> createState() => _BlendDonutState();
}

class _BlendDonutState extends State<_BlendDonut> {
  int _touched = -1;

  static const _colors = [
    Color(0xFF1A56DB),
    Color(0xFF057A55),
    Color(0xFFE3A008),
    Color(0xFF9061F9),
    Color(0xFFFF5A1F),
    Color(0xFF0E9F6E),
  ];

  @override
  Widget build(BuildContext context) {
    final active = widget.ratios.asMap().entries.where((e) => e.value > 0.05).toList();
    if (active.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Blend Composition',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 12),
            SizedBox(
              height: 200,
              child: PieChart(
                PieChartData(
                  sections: active.map((e) {
                    final i = e.key;
                    final ratio = e.value;
                    final isTouched = i == _touched;
                    final color = _colors[i % _colors.length];
                    return PieChartSectionData(
                      color: color,
                      value: ratio,
                      title: isTouched
                          ? '${widget.names[i]}\n${ratio.toStringAsFixed(1)}%'
                          : ratio >= 10
                              ? '${ratio.toStringAsFixed(0)}%'
                              : '',
                      radius: isTouched ? 85 : 70,
                      titleStyle: TextStyle(
                        fontSize: isTouched ? 12 : 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  pieTouchData: PieTouchData(
                    touchCallback: (event, response) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            response?.touchedSection == null) {
                          _touched = -1;
                          return;
                        }
                        _touched = response!.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                  centerSpaceRadius: 40,
                  sectionsSpace: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 6,
              children: active.map((e) {
                final color = _colors[e.key % _colors.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                          color: color, borderRadius: BorderRadius.circular(2)),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${widget.names[e.key]}  ${e.value.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Per-cotton strength bar chart ─────────────────────────────────────────────

class _StrengthBars extends StatelessWidget {
  final List<String> names;
  final List<double> strengths;
  final double target;

  const _StrengthBars({
    required this.names,
    required this.strengths,
    required this.target,
  });

  static const _colors = [
    Color(0xFF1A56DB),
    Color(0xFF057A55),
    Color(0xFFE3A008),
    Color(0xFF9061F9),
    Color(0xFFFF5A1F),
    Color(0xFF0E9F6E),
  ];

  @override
  Widget build(BuildContext context) {
    if (strengths.isEmpty) return const SizedBox.shrink();
    final maxY = (strengths.fold(target, (a, b) => a > b ? a : b) * 1.2).ceilToDouble();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Predicted Strength vs Target',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 2),
            Text('RKM per cotton variety',
                style: TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
            const SizedBox(height: 14),
            SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  maxY: maxY,
                  alignment: BarChartAlignment.spaceAround,
                  barGroups: strengths.asMap().entries.map((e) {
                    return BarChartGroupData(
                      x: e.key,
                      barRods: [
                        BarChartRodData(
                          toY: e.value,
                          color: e.value >= target
                              ? _colors[e.key % _colors.length]
                              : AppTheme.textSecondary.withValues(alpha: 0.5),
                          width: 24,
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                      ],
                    );
                  }).toList(),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 38,
                        getTitlesWidget: (v, _) => Text(
                          v.toStringAsFixed(0),
                          style: const TextStyle(
                              fontSize: 10, color: AppTheme.textSecondary),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (v, _) {
                          final i = v.toInt();
                          if (i < 0 || i >= names.length) return const SizedBox();
                          return Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              names[i],
                              style: const TextStyle(
                                  fontSize: 9, color: AppTheme.textSecondary),
                            ),
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(drawVerticalLine: false),
                  extraLinesData: ExtraLinesData(
                    horizontalLines: [
                      HorizontalLine(
                        y: target,
                        color: AppTheme.danger,
                        strokeWidth: 1.5,
                        dashArray: [6, 4],
                        label: HorizontalLineLabel(
                          show: true,
                          alignment: Alignment.topRight,
                          labelResolver: (_) =>
                              'Target ${target.toStringAsFixed(0)} RKM',
                          style: const TextStyle(
                              fontSize: 10,
                              color: AppTheme.danger,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
