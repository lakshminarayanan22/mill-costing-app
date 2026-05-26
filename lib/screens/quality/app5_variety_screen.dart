import 'package:flutter/material.dart';
import '../../quality/data/fibre_parameters.dart';
import '_qd_widgets.dart';

class App5VarietyScreen extends StatefulWidget {
  const App5VarietyScreen({super.key});

  @override
  State<App5VarietyScreen> createState() => _App5VarietyScreenState();
}

class _App5VarietyScreenState extends State<App5VarietyScreen> {
  FibreVariety? _selected;
  final _all = kAllVarieties;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App 5 — Fibre Parameters by Variety')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const QdInfoCard(
              'Displays maximum / typical reference values for each cotton variety '
              'from the built-in database.',
            ),
            const SizedBox(height: 14),
            const QdSectionLabel('Select Cotton Variety'),
            DropdownButtonFormField<FibreVariety>(
              decoration: const InputDecoration(labelText: 'Cotton variety'),
              // ignore: deprecated_member_use
              value: _selected,
              items: _all.map((v) => DropdownMenuItem(
                value: v,
                child: Text('${v.slNo}. ${v.varietyName} (${v.group})'),
              )).toList(),
              onChanged: (v) => setState(() => _selected = v),
            ),
            if (_selected != null) ...[
              const SizedBox(height: 16),
              const QdSectionLabel('Fibre Parameters (Maximum Values)'),
              Expanded(
                child: SingleChildScrollView(
                  child: QdResultCard(children: [
                    _row('Group', _selected!.group),
                    _row('Variety Name', _selected!.varietyName),
                    const Divider(height: 12),
                    _row('2.5% span length (mm)', _fmt(_selected!.span25mm)),
                    _row('50% span length (mm)', _fmt(_selected!.span50mm)),
                    _row('Uniformity Index', _fmt(_selected!.uniformityIndex)),
                    _row('Uniformity Ratio', _fmt(_selected!.uniformityRatio)),
                    const Divider(height: 12),
                    _row('Strength 1/8" (g/tex)', _fmt(_selected!.strength18Gtex)),
                    _row('Strength (cN/tex)', _fmt(_selected!.strengthCnTex)),
                    _row('Micronaire', _fmt(_selected!.mic)),
                    _row('Breaking Elongation %', _fmt(_selected!.breakingElongPct)),
                    _row('Short Fibre Content', _fmt(_selected!.shortFibreContent)),
                    const Divider(height: 12),
                    _row('Reflectance Rd', _fmt(_selected!.reflectanceRd)),
                    _row('Yellowness +b', _fmt(_selected!.yellownessB)),
                    const Divider(height: 12),
                    _row('Neps / g', _fmt(_selected!.nepsPerG)),
                    _row('Neps size (µm)', _fmt(_selected!.nepsSizeUm)),
                    _row('Seed coat neps / g', _fmt(_selected!.seedCoatNepsPerG)),
                    _row('SCN size (µm)', _fmt(_selected!.scnSizeUm)),
                    _row('SFC(n) %', _fmt(_selected!.sfcN)),
                  ]),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return QdResultRow(label, value);
  }

  String _fmt(double? v) => v == null ? '—' : v.toStringAsFixed(v.truncateToDouble() == v ? 0 : 1);
}
