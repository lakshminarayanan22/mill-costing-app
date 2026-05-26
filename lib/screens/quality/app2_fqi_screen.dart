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
              const QdSectionLabel('Result'),
              QdResultCard(children: [
                if (_indexSel == 1 || true) ...[
                  QdResultRow('FQI', _result!.fqi.toStringAsFixed(3),
                      highlight: _indexSel == 1),
                ],
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
