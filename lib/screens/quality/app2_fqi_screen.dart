import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../quality/qd_engine.dart';
import '../../quality/tracker_service.dart';
import '../../theme/app_theme.dart';
import '_qd_widgets.dart';

class App2FqiScreen extends ConsumerStatefulWidget {
  const App2FqiScreen({super.key});

  @override
  ConsumerState<App2FqiScreen> createState() => _App2FqiScreenState();
}

class _App2FqiScreenState extends ConsumerState<App2FqiScreen> {
  // Admin fields
  final _mixNumber = TextEditingController(text: '1');
  final _cottonName = TextEditingController(text: 'MCU-5');
  final _lotNo = TextEditingController(text: '101');
  final _totalBales = TextEditingController(text: '38');
  final _balesThisLot = TextEditingController(text: '5');

  // Fibre inputs
  final _uhml = TextEditingController(text: '33');
  final _sl50 = TextEditingController(text: '15');
  final _ui = TextEditingController(text: '87');
  final _str = TextEditingController(text: '46.3');
  final _mic = TextEditingController(text: '4.38');
  final _rd = TextEditingController(text: '75.5');
  final _yb = TextEditingController(text: '9');
  final _elong = TextEditingController(text: '6.5');
  final _sfi = TextEditingController(text: '6');
  final _mat = TextEditingController(text: '0.87');

  int _indexSel = 2; // 1=FQI, 2=SCI, 3=PQI
  int _sciMode = 1; // 1–4
  bool _useUR = false;
  final _ur = TextEditingController(text: '47');

  App2Result? _result;
  DateTime _date = DateTime.now();

  double _uiValue() {
    if (_useUR) {
      final ur = double.tryParse(_ur.text) ?? 47;
      return ur * 2;
    }
    return double.tryParse(_ui.text) ?? 87;
  }

  void _calc() {
    try {
      final inp = App2Input(
        uhmlMm: double.parse(_uhml.text),
        sl50: double.parse(_sl50.text),
        ui: _uiValue(),
        str: double.parse(_str.text),
        mic: double.parse(_mic.text),
        rd: double.parse(_rd.text),
        yb: double.parse(_yb.text),
        elong: double.parse(_elong.text),
        sfi: double.parse(_sfi.text),
        mat: double.parse(_mat.text),
        indexSel: _indexSel,
        sciMode: _sciMode,
      );
      setState(() => _result = calcApp2(inp));
    } catch (_) {
      setState(() => _result = null);
    }
  }

  String get _selectedIndexName {
    switch (_indexSel) {
      case 1: return 'FQI';
      case 3: return 'PQI';
      default: return 'SCI';
    }
  }

  double? get _selectedIndexValue {
    if (_result == null) return null;
    switch (_indexSel) {
      case 1: return _result!.fqi;
      case 3: return _result!.pqi;
      default: return _result!.sci;
    }
  }

  void _sendToTracker() {
    if (_selectedIndexValue == null) return;
    final record = TrackerRecord(
      id: '',
      date: _date,
      mixNumber: _mixNumber.text,
      varietyName: _cottonName.text,
      lotNo: _lotNo.text,
      totalBalesInMix: int.tryParse(_totalBales.text) ?? 0,
      balesOfThisLot: int.tryParse(_balesThisLot.text) ?? 0,
      qualityIndex: _selectedIndexValue!,
      indexLabel: _selectedIndexName,
    );
    ref.read(trackerProvider.notifier).add(record);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sent to Tracker: $_selectedIndexName ${_selectedIndexValue!.toStringAsFixed(2)}'),
        backgroundColor: AppTheme.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App 2 — Fibre Quality Index')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Index selector
            const QdSectionLabel('Index to Calculate'),
            Row(
              children: [
                _IndexChip('FQI', 1, _indexSel, (v) => setState(() => _indexSel = v)),
                const SizedBox(width: 8),
                _IndexChip('SCI', 2, _indexSel, (v) => setState(() => _indexSel = v)),
                const SizedBox(width: 8),
                _IndexChip('PQI', 3, _indexSel, (v) => setState(() => _indexSel = v)),
              ],
            ),
            if (_indexSel == 2) ...[
              const SizedBox(height: 10),
              const QdSectionLabel('SCI Mode'),
              QdDropdown<int>(
                label: 'SCI calculation mode',
                value: _sciMode,
                items: const [
                  DropdownMenuItem(value: 1, child: Text('HVI-HVI with colour')),
                  DropdownMenuItem(value: 2, child: Text('HVI-ICC with colour')),
                  DropdownMenuItem(value: 3, child: Text('HVI-HVI without colour')),
                  DropdownMenuItem(value: 4, child: Text('HVI-ICC without colour')),
                ],
                onChanged: (v) => setState(() => _sciMode = v ?? 1),
              ),
            ],
            const SizedBox(height: 16),
            const QdSectionLabel('Administrative'),
            Row(children: [
              Expanded(child: QdField('Mix Number', _mixNumber, '1')),
              const SizedBox(width: 10),
              Expanded(child: QdField('Cotton Name', _cottonName, 'MCU-5')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: QdField('Lot Number', _lotNo, '101')),
              const SizedBox(width: 10),
              Expanded(child: QdField('Total Bales in Mix', _totalBales, '38')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: QdField('Bales of This Lot', _balesThisLot, '5')),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2030),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                  child: InputDecorator(
                    decoration: const InputDecoration(labelText: 'Date'),
                    child: Text(
                      '${_date.day}/${_date.month}/${_date.year}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 16),
            const QdSectionLabel('HVI Fibre Inputs'),
            Row(children: [
              Expanded(child: QdField('UHML (mm)', _uhml, '33')),
              const SizedBox(width: 10),
              Expanded(child: QdField('50% span length (mm)', _sl50, '15')),
            ]),
            const SizedBox(height: 10),
            // UI / UR toggle
            Row(
              children: [
                const Text('Use:'),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('UI'),
                  selected: !_useUR,
                  onSelected: (_) => setState(() => _useUR = false),
                  selectedColor: AppTheme.primaryLight,
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('UR (×2 = UI)'),
                  selected: _useUR,
                  onSelected: (_) => setState(() => _useUR = true),
                  selectedColor: AppTheme.primaryLight,
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (!_useUR)
              QdField('Uniformity Index (UI %)', _ui, '87')
            else
              QdField('Uniformity Ratio (UR)', _ur, '47'),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: QdField('Fibre Strength (cN/tex)', _str, '46.3')),
              const SizedBox(width: 10),
              Expanded(child: QdField('Micronaire', _mic, '4.38')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: QdField('Reflectance Rd', _rd, '75.5')),
              const SizedBox(width: 10),
              Expanded(child: QdField('Yellowness +b', _yb, '9')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: QdField('Elongation %', _elong, '6.5')),
              const SizedBox(width: 10),
              Expanded(child: QdField('Short Fibre Index (SFI)', _sfi, '6')),
            ]),
            const SizedBox(height: 10),
            QdField('Maturity Coefficient', _mat, '0.87'),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calc,
                child: const Text('Calculate'),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 20),
              // ── Primary score meter ──────────────────────────────────────
              if (_selectedIndexValue != null)
                _ScoreMeter(
                  label: _selectedIndexName,
                  value: _selectedIndexValue!,
                  cottonName: _cottonName.text,
                ),
              const SizedBox(height: 14),
              // ── All three values ─────────────────────────────────────────
              const QdSectionLabel('All Indices'),
              QdResultCard(children: [
                QdResultRow('FQI', _result!.fqi.toStringAsFixed(3),
                    highlight: _indexSel == 1),
                const Divider(height: 8),
                QdResultRow('SCI (mode 1 HVI-HVI colour)', _result!.sci.toStringAsFixed(3),
                    highlight: _indexSel == 2 && _sciMode == 1),
                const Divider(height: 8),
                QdResultRow('PQI', _result!.pqi.toStringAsFixed(3),
                    highlight: _indexSel == 3),
              ]),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _sendToTracker,
                  icon: const Icon(Icons.send, size: 16),
                  label: Text('Send to Tracker ($_selectedIndexName)'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    side: const BorderSide(color: AppTheme.primary),
                    foregroundColor: AppTheme.primary,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Score meter card ──────────────────────────────────────────────────────────
// Shows the selected quality index as a large colour-coded score with grade label.

class _ScoreMeter extends StatelessWidget {
  final String label;
  final double value;
  final String cottonName;

  const _ScoreMeter({
    required this.label,
    required this.value,
    required this.cottonName,
  });

  // SCI typical range: 100–170, FQI: 80–180, PQI: 100–200
  // Zones (normalised to 0–1 using a 60–200 scale):
  static const double _scaleMin = 60;
  static const double _scaleMax = 200;

  String get _grade {
    if (value >= 160) return 'Excellent';
    if (value >= 130) return 'Good';
    if (value >= 100) return 'Average';
    return 'Below Average';
  }

  Color get _gradeColor {
    if (value >= 160) return AppTheme.success;
    if (value >= 130) return const Color(0xFF1A56DB);
    if (value >= 100) return AppTheme.warning;
    return AppTheme.danger;
  }

  double get _fraction =>
      ((value - _scaleMin) / (_scaleMax - _scaleMin)).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        cottonName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: _gradeColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _gradeColor.withValues(alpha: 0.35)),
                  ),
                  child: Text(
                    _grade,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: _gradeColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Large score value
            Text(
              value.toStringAsFixed(1),
              style: TextStyle(
                fontSize: 52,
                fontWeight: FontWeight.w800,
                color: _gradeColor,
                height: 1,
              ),
            ),
            const SizedBox(height: 16),
            // Progress bar with zone markers
            Column(
              children: [
                // Zone colour bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 10,
                    child: Row(
                      children: [
                        Expanded(
                            flex: 40,
                            child: Container(color: AppTheme.danger)),
                        Expanded(
                            flex: 30,
                            child: Container(color: AppTheme.warning)),
                        Expanded(
                            flex: 30,
                            child: Container(
                                color: const Color(0xFF1A56DB))),
                        Expanded(
                            flex: 40,
                            child: Container(color: AppTheme.success)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Needle
                LayoutBuilder(
                  builder: (ctx, constraints) {
                    final pos = (_fraction * constraints.maxWidth)
                        .clamp(4.0, constraints.maxWidth - 4);
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const SizedBox(height: 12, width: double.infinity),
                        Positioned(
                          left: pos - 4,
                          top: -6,
                          child: Container(
                            width: 8,
                            height: 18,
                            decoration: BoxDecoration(
                              color: _gradeColor,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 2),
                // Scale labels
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('60',
                        style: TextStyle(
                            fontSize: 10, color: AppTheme.textSecondary)),
                    Text('100',
                        style: TextStyle(
                            fontSize: 10, color: AppTheme.textSecondary)),
                    Text('130',
                        style: TextStyle(
                            fontSize: 10, color: AppTheme.textSecondary)),
                    Text('160',
                        style: TextStyle(
                            fontSize: 10, color: AppTheme.textSecondary)),
                    Text('200',
                        style: TextStyle(
                            fontSize: 10, color: AppTheme.textSecondary)),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IndexChip extends StatelessWidget {
  final String label;
  final int value;
  final int current;
  final ValueChanged<int> onChanged;

  const _IndexChip(this.label, this.value, this.current, this.onChanged);

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onChanged(value),
      selectedColor: AppTheme.primaryLight,
      labelStyle: TextStyle(
        color: selected ? AppTheme.primary : AppTheme.textSecondary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
