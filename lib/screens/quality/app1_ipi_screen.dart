import 'package:flutter/material.dart';
import '../../quality/qd_engine.dart';
import '../../theme/app_theme.dart';
import '_qd_widgets.dart';

class App1IpiScreen extends StatefulWidget {
  const App1IpiScreen({super.key});

  @override
  State<App1IpiScreen> createState() => _App1IpiScreenState();
}

class _App1IpiScreenState extends State<App1IpiScreen> {
  final _fine = TextEditingController(text: '4');
  final _sl50 = TextEditingController(text: '16');
  final _sfi = TextEditingController(text: '10');
  final _count = TextEditingController(text: '60');
  final _trash = TextEditingController(text: '0.03');
  final _neps = TextEditingController(text: '0.02');
  int _ytype = 3;
  App1Result? _result;

  static const _ytypeLabels = [
    'Carded hosiery',
    'Combed hosiery',
    'Carded weaving',
    'Combed weaving',
  ];

  void _calc() {
    try {
      final inp = App1Input(
        fine: double.parse(_fine.text),
        sl50: double.parse(_sl50.text),
        sfi: double.parse(_sfi.text),
        count: double.parse(_count.text),
        trash: double.parse(_trash.text),
        neps: double.parse(_neps.text),
        ytype: _ytype,
      );
      setState(() => _result = calcApp1(inp));
    } catch (_) {
      setState(() => _result = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App 1 — Yarn IPI from HVI')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const QdInfoCard(
              'Predicts total imperfections per km (IPI) of ring yarn '
              'from HVI fibre data. A normal ring yarn will have 40–50% '
              'more IPI than a compact yarn.',
            ),
            const SizedBox(height: 16),
            const QdSectionLabel('HVI Fibre Inputs'),
            Row(children: [
              Expanded(child: QdField('Micronaire', _fine, 'Fine')),
              const SizedBox(width: 10),
              Expanded(child: QdField('50% span length (mm)', _sl50, 'SL50')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: QdField('Short Fibre Index', _sfi, 'SFI')),
              const SizedBox(width: 10),
              Expanded(child: QdField('Yarn count (Ne)', _count, 'Count')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: QdField('Trash % (drawing sliver)', _trash, 'e.g. 0.03')),
              const SizedBox(width: 10),
              Expanded(child: QdField('Neps/mg (drawing sliver)', _neps, 'e.g. 0.02')),
            ]),
            const SizedBox(height: 12),
            const QdSectionLabel('Yarn Type'),
            Wrap(
              spacing: 8,
              children: List.generate(4, (i) {
                return ChoiceChip(
                  label: Text(_ytypeLabels[i]),
                  selected: _ytype == i + 1,
                  onSelected: (_) => setState(() => _ytype = i + 1),
                  selectedColor: AppTheme.primaryLight,
                  labelStyle: TextStyle(
                    color: _ytype == i + 1 ? AppTheme.primary : AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calc,
                child: const Text('Calculate IPI'),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 20),
              const QdSectionLabel('Result'),
              QdResultCard(children: [
                QdResultRow('Base IPI', _result!.baseIPI.toStringAsFixed(2)),
                const Divider(height: 16),
                QdResultRow('Total IPI / km', _result!.totalIPI.toStringAsFixed(2),
                    highlight: true),
              ]),
              const SizedBox(height: 8),
              const QdInfoCard(
                'Note: A normal / ring yarn will have 40–50% more IPI '
                'than a compact yarn.',
              ),
            ],
          ],
        ),
      ),
    );
  }
}
