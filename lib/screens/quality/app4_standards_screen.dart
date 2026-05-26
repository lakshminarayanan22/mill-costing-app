import 'package:flutter/material.dart';
import '../../quality/qd_engine.dart';
import '../../theme/app_theme.dart';
import '_qd_widgets.dart';

class App4StandardsScreen extends StatefulWidget {
  const App4StandardsScreen({super.key});

  @override
  State<App4StandardsScreen> createState() => _App4StandardsScreenState();
}

class _App4StandardsScreenState extends State<App4StandardsScreen> {
  // SFI calc inputs
  final _uhmMm = TextEditingController(text: '33');
  final _ui = TextEditingController(text: '87');
  final _sl2Mm = TextEditingController(text: '29');
  final _ur = TextEditingController(text: '47');

  double? _sfi1, _sfi2;

  void _calcSfi() {
    try {
      setState(() {
        _sfi1 = calcSfiFromUhm(double.parse(_uhmMm.text), double.parse(_ui.text));
        _sfi2 = calcSfiFromSl2(double.parse(_sl2Mm.text), double.parse(_ur.text));
      });
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App 4 — Cotton Quality Standards')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _table('Fibre Length Classification (2.5% span length)', [
              ['Class', '2.5% span length (mm)'],
              ['Extra Long Staple (ELS)', '≥ 32.5'],
              ['Long staple', '27.5 – 32'],
              ['Medium long staple', '25 – 27'],
              ['Medium staple', '20.5 – 24.5'],
              ['Short staple', '≤ 20'],
            ]),
            const SizedBox(height: 16),
            _table('Uniformity Ratio Standards', [
              ['Good', 'Average', 'Poor'],
              ['50', '45', '43'],
            ]),
            const SizedBox(height: 16),
            _table('Uniformity Index Standards & Uster Grades', [
              ['Rating', 'UI value', 'Uster grade', 'UI band'],
              ['Good', '85', 'Very high', '> 86'],
              ['Average', '82', 'High', '83 – 85'],
              ['Poor', '80', 'Average', '80 – 82'],
              ['', '', 'Low', '77 – 79'],
              ['', '', 'Very low', '< 76'],
            ]),
            const SizedBox(height: 16),
            _table('Micronaire Standards', [
              ['Rating', 'Value', 'Uster band'],
              ['Fine', '3', '< 3 (very fine) / 3.1–3.9 (fine)'],
              ['Average', '4', '4.0 – 4.9'],
              ['Coarse', '5', '5.0 – 5.9 / > 6 (very coarse)'],
            ]),
            const SizedBox(height: 16),
            _table('Maturity Coefficient', [
              ['Good', 'Average', 'Poor'],
              ['0.85', '0.80', '0.70'],
            ]),
            const SizedBox(height: 16),
            _table('Fibre Strength (3 mm gauge)', [
              ['Rating', 'g/tex ICC', 'g/tex HVI (=ICC×1.23)', 'Uster (ICC)'],
              ['High', '30', '36.9', '28 – 30'],
              ['Average', '24', '29.52', '25 – 27'],
              ['Low', '18', '22.14', '22 – 24'],
              ['Very low', '—', '—', '< 21'],
            ]),
            const SizedBox(height: 16),
            _table('Allowable Trash % by Count', [
              ['Count', 'Max Trash %'],
              ['20', '4.5%'],
              ['30', '3.5%'],
              ['40', '3.0%'],
              ['60', '3.0%'],
              ['80', '2.5%'],
              ['100', '2.0%'],
            ]),
            const SizedBox(height: 16),
            const QdInfoCard(
              'A 1% shift in lab relative humidity shifts fibre strength by about 1%.',
            ),
            const SizedBox(height: 20),
            const QdSectionLabel('SFI Live Calculator'),
            const Text(
              'Formula 1: SFI from UHM and UI',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: QdField('UHM (mm)', _uhmMm, '33')),
              const SizedBox(width: 10),
              Expanded(child: QdField('UI %', _ui, '87')),
            ]),
            const SizedBox(height: 10),
            const Text(
              'Formula 2: SFI from 2.5% span length and UR',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: QdField('2.5% span length (mm)', _sl2Mm, '29')),
              const SizedBox(width: 10),
              Expanded(child: QdField('UR', _ur, '47')),
            ]),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calcSfi,
                child: const Text('Calculate SFI'),
              ),
            ),
            if (_sfi1 != null) ...[
              const SizedBox(height: 12),
              QdResultCard(children: [
                QdResultRow('SFI (from UHM + UI)', _sfi1!.toStringAsFixed(2), highlight: true),
                QdResultRow('SFI (from 2.5% span + UR)', _sfi2!.toStringAsFixed(2), highlight: true),
              ]),
            ],
          ],
        ),
      ),
    );
  }

  Widget _table(String title, List<List<String>> rows) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary)),
        const SizedBox(height: 6),
        Card(
          child: Table(
            border: TableBorder.all(color: AppTheme.divider, width: 0.5),
            children: rows.asMap().entries.map((e) {
              final isHeader = e.key == 0;
              return TableRow(
                decoration: BoxDecoration(
                  color: isHeader ? AppTheme.primaryLight : Colors.white,
                ),
                children: e.value.map((cell) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  child: Text(
                    cell,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isHeader ? FontWeight.w700 : FontWeight.normal,
                      color: isHeader ? AppTheme.primary : AppTheme.textPrimary,
                    ),
                  ),
                )).toList(),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
