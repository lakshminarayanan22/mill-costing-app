import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../quality/qd_engine.dart';
import '../../theme/app_theme.dart';
import '_qd_widgets.dart';

class App3YarnQualityScreen extends StatefulWidget {
  const App3YarnQualityScreen({super.key});

  @override
  State<App3YarnQualityScreen> createState() => _App3YarnQualityScreenState();
}

class _App3YarnQualityScreenState extends State<App3YarnQualityScreen> {
  int _route = 1; // 1=HVI, 2=AFIS
  int _ytype = 2; // 1–4

  // Process inputs
  final _count = TextEditingController(text: '60');
  final _tm = TextEditingController(text: '3.8');
  final _rovHank = TextEditingController(text: '1.6');
  final _rovUm = TextEditingController(text: '4');
  final _rovCVm = TextEditingController(text: '3');
  final _rovCV1m = TextEditingController(text: '2.83');
  final _spindle = TextEditingController(text: '18000');

  // HVI inputs
  final _uhml = TextEditingController(text: '33');
  final _str = TextEditingController(text: '46.3');
  final _mic = TextEditingController(text: '4.38');
  final _ui = TextEditingController(text: '87');
  final _rd = TextEditingController(text: '75.5');
  final _yb = TextEditingController(text: '9');
  final _elong = TextEditingController(text: '6.5');
  final _sfi = TextEditingController(text: '6');

  // AFIS inputs
  final _neps = TextEditingController(text: '80.5');
  final _lw = TextEditingController(text: '28.1');
  final _sfcw = TextEditingController(text: '5.15');
  final _uqlw = TextEditingController(text: '33.5');
  final _ln = TextEditingController(text: '24.5');
  final _sfcn = TextEditingController(text: '14.75');
  final _uqln = TextEditingController(text: '30.9');
  final _dm = TextEditingController(text: '13.5');
  final _span25n = TextEditingController(text: '43.35');
  final _dust = TextEditingController(text: '92.5');
  final _trash = TextEditingController(text: '14.5');
  final _vfm = TextEditingController(text: '0.234');

  App3Result? _result;

  static const _ytypeLabels = [
    'Combed Normal',
    'Combed Compact',
    'Carded Normal',
    'Carded Compact',
  ];

  void _calc() {
    try {
      final proc = App3ProcessInput(
        count: double.parse(_count.text),
        tm: double.parse(_tm.text),
        rovHank: double.parse(_rovHank.text),
        rovUm: double.parse(_rovUm.text),
        rovCVm: double.parse(_rovCVm.text),
        rovCV1m: double.parse(_rovCV1m.text),
        spindle: double.parse(_spindle.text),
      );
      final hvi = HviInput(
        uhmlMm: double.parse(_uhml.text),
        str: double.parse(_str.text),
        mic: double.parse(_mic.text),
        ui: double.parse(_ui.text),
        rd: double.parse(_rd.text),
        yb: double.parse(_yb.text),
        elong: double.parse(_elong.text),
        sfi: double.parse(_sfi.text),
      );
      AfisInput? afis;
      if (_route == 2) {
        afis = AfisInput(
          neps: double.parse(_neps.text),
          lw: double.parse(_lw.text),
          sfcw: double.parse(_sfcw.text),
          uqlw: double.parse(_uqlw.text),
          ln: double.parse(_ln.text),
          sfcn: double.parse(_sfcn.text),
          uqln: double.parse(_uqln.text),
          dm: double.parse(_dm.text),
          span25n: double.parse(_span25n.text),
          dust: double.parse(_dust.text),
          trash: double.parse(_trash.text),
          vfm: double.parse(_vfm.text),
        );
      }
      setState(() {
        _result = calcApp3(
          route: _route,
          ytype: _ytype,
          hvi: hvi,
          afis: afis,
          proc: proc,
        );
      });
    } catch (_) {
      setState(() => _result = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App 3 — Yarn Quality Prediction')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const QdInfoCard(
              'Prediction is based on the correlation between fibre and '
              'yarn properties achieved in GOOD mills.',
            ),
            const SizedBox(height: 12),
            const QdSectionLabel('Route'),
            Row(children: [
              ChoiceChip(
                label: const Text('HVI'),
                selected: _route == 1,
                onSelected: (_) => setState(() => _route = 1),
                selectedColor: AppTheme.primaryLight,
              ),
              const SizedBox(width: 8),
              ChoiceChip(
                label: const Text('AFIS'),
                selected: _route == 2,
                onSelected: (_) => setState(() => _route = 2),
                selectedColor: AppTheme.primaryLight,
              ),
            ]),
            const SizedBox(height: 10),
            const QdSectionLabel('Yarn Type'),
            Wrap(
              spacing: 8,
              children: List.generate(4, (i) => ChoiceChip(
                label: Text(_ytypeLabels[i]),
                selected: _ytype == i + 1,
                onSelected: (_) => setState(() => _ytype = i + 1),
                selectedColor: AppTheme.primaryLight,
              )),
            ),
            const SizedBox(height: 14),
            const QdSectionLabel('Ring Frame / Process Inputs'),
            Row(children: [
              Expanded(child: QdField('Count (Ne)', _count, '60')),
              const SizedBox(width: 10),
              Expanded(child: QdField('Twist Multiplier (TM)', _tm, '3.8')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: QdField('Roving Hank (Ne)', _rovHank, '1.6')),
              const SizedBox(width: 10),
              Expanded(child: QdField('Roving Um %', _rovUm, '4')),
            ]),
            const SizedBox(height: 10),
            Row(children: [
              Expanded(child: QdField('Roving CVm %', _rovCVm, '3')),
              const SizedBox(width: 10),
              Expanded(child: QdField('Roving CV(1m)', _rovCV1m, '2.83')),
            ]),
            const SizedBox(height: 10),
            QdField('Spindle Speed (RPM)', _spindle, '18000'),
            const SizedBox(height: 14),
            if (_route == 1) ...[
              const QdSectionLabel('HVI Fibre Inputs'),
              Row(children: [
                Expanded(child: QdField('UHML (mm)', _uhml, '33')),
                const SizedBox(width: 10),
                Expanded(child: QdField('Fibre Strength (cN/tex)', _str, '46.3')),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: QdField('Micronaire', _mic, '4.38')),
                const SizedBox(width: 10),
                Expanded(child: QdField('Uniformity Index (UI %)', _ui, '87')),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: QdField('Elongation %', _elong, '6.5')),
                const SizedBox(width: 10),
                Expanded(child: QdField('Short Fibre Index (SFI)', _sfi, '6')),
              ]),
            ] else ...[
              const QdSectionLabel('AFIS Fibre Inputs'),
              Row(children: [
                Expanded(child: QdField('Neps (cnt/g)', _neps, '80.5')),
                const SizedBox(width: 10),
                Expanded(child: QdField('Fibre diameter (µm)', _dm, '13.5')),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: QdField('Mean length by weight (mm)', _lw, '28.1')),
                const SizedBox(width: 10),
                Expanded(child: QdField('SFC by weight (%)', _sfcw, '5.15')),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: QdField('UQL by weight (mm)', _uqlw, '33.5')),
                const SizedBox(width: 10),
                Expanded(child: QdField('Dust (cnt/g)', _dust, '92.5')),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: QdField('Mean length by number (mm)', _ln, '24.5')),
                const SizedBox(width: 10),
                Expanded(child: QdField('SFC by number (%)', _sfcn, '14.75')),
              ]),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: QdField('Trash (cnt/g)', _trash, '14.5')),
                const SizedBox(width: 10),
                Expanded(child: QdField('VFM %', _vfm, '0.234')),
              ]),
            ],
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calc,
                child: const Text('Predict Yarn Quality'),
              ),
            ),
            if (_result != null) ...[
              const SizedBox(height: 20),
              const QdSectionLabel('Derived Quantities'),
              QdResultCard(children: [
                QdResultRow('Yarn Tex', _result!.yarnTex.toStringAsFixed(4)),
                QdResultRow('TPM', _result!.tpm.toStringAsFixed(2)),
                QdResultRow('Roving Tex', _result!.rovTex.toStringAsFixed(4)),
                QdResultRow('Roving CV (regr.)', _result!.rovCV.toStringAsFixed(4)),
                QdResultRow('Fibres in cross-section', _result!.fibresInCrossSection.toStringAsFixed(2)),
                QdResultRow('Limiting U%', _result!.limitingU.toStringAsFixed(4)),
              ]),
              const SizedBox(height: 12),
              const QdSectionLabel('Predicted Yarn Quality'),
              QdResultCard(children: [
                QdResultRow('Tenacity (cN/tex)', _result!.tenacity.toStringAsFixed(4), highlight: true),
                QdResultRow('Elongation %', _result!.elongation.toStringAsFixed(4), highlight: true),
                QdResultRow('Evenness U%', _result!.uPct.toStringAsFixed(4), highlight: true),
                QdResultRow('Hairiness (Uster)', _result!.hairinessUster.toStringAsFixed(4), highlight: true),
                if (_result!.hairinessS3 != null)
                  QdResultRow('Hairiness S3 (Zweigle)', _result!.hairinessS3!.toStringAsFixed(2)),
              ]),
              const SizedBox(height: 12),
              const QdSectionLabel('S3 Hairiness Components'),
              QdResultCard(children: [
                QdResultRow('S3 Base', _result!.s3Base.toStringAsFixed(2)),
                QdResultRow('v74 (combed normal)', _result!.v74.toStringAsFixed(2)),
                QdResultRow('v75 (combed compact)', _result!.v75.toStringAsFixed(2)),
                QdResultRow('v76 (carded normal)', _result!.v76.toStringAsFixed(2)),
                QdResultRow('v77 (carded compact)', _result!.v77.toStringAsFixed(2)),
              ]),
              const SizedBox(height: 16),
              _YarnQualityRadarCard(result: _result!),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Yarn quality radar / bar chart ────────────────────────────────────────────
// Shows predicted quality parameters as a radar chart (4 normalised axes).

class _YarnQualityRadarCard extends StatelessWidget {
  final App3Result result;
  const _YarnQualityRadarCard({required this.result});

  // Normalise a value into 0–1 score where 1 = good, 0 = poor.
  // For "lower is better" params we invert.
  static double _norm(double val, double best, double worst) {
    if ((worst - best).abs() < 1e-9) return 0.5;
    return ((val - worst) / (best - worst)).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    // Good-mill reference ranges (combed 60s typical)
    // Tenacity: 14–20 cN/tex (higher = better)
    // Elongation: 4–7% (higher = better)
    // U%: 7–12% (lower = better)
    // Hairiness: 3–6 (lower = better)
    final params = [
      (
        label: 'Tenacity',
        unit: 'cN/tex',
        value: result.tenacity,
        score: _norm(result.tenacity, 20, 12),
        color: AppTheme.componentColors[0],
      ),
      (
        label: 'Elongation',
        unit: '%',
        value: result.elongation,
        score: _norm(result.elongation, 7, 3),
        color: AppTheme.componentColors[2],
      ),
      (
        label: 'Evenness U%',
        unit: '%',
        value: result.uPct,
        score: _norm(result.uPct, 7, 13),
        color: AppTheme.componentColors[4],
      ),
      (
        label: 'Hairiness',
        unit: '',
        value: result.hairinessUster,
        score: _norm(result.hairinessUster, 3, 7),
        color: AppTheme.componentColors[3],
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Quality Score (vs Good Mill)',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
            const SizedBox(height: 2),
            const Text(
              'Bar = how close the predicted value is to a good-mill benchmark. Tap to see details.',
              style: TextStyle(fontSize: 11, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 16),
            ...params.map((p) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(p.label,
                                style: const TextStyle(
                                    fontSize: 13, fontWeight: FontWeight.w500)),
                          ),
                          Text(
                            '${p.value.toStringAsFixed(2)}${p.unit.isNotEmpty ? ' ${p.unit}' : ''}',
                            style: const TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Stack(
                        children: [
                          Container(
                            height: 10,
                            decoration: BoxDecoration(
                              color: AppTheme.surface,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: p.score,
                            child: Container(
                              height: 10,
                              decoration: BoxDecoration(
                                color: p.score >= 0.7
                                    ? AppTheme.success
                                    : p.score >= 0.4
                                        ? AppTheme.warning
                                        : AppTheme.danger,
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        p.score >= 0.7
                            ? 'Good'
                            : p.score >= 0.4
                                ? 'Average'
                                : 'Below average',
                        style: TextStyle(
                          fontSize: 10,
                          color: p.score >= 0.7
                              ? AppTheme.success
                              : p.score >= 0.4
                                  ? AppTheme.warning
                                  : AppTheme.danger,
                        ),
                      ),
                    ],
                  ),
                )),
            const SizedBox(height: 4),
            // Radar chart using fl_chart
            SizedBox(
              height: 220,
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      fillColor: AppTheme.primary.withValues(alpha: 0.15),
                      borderColor: AppTheme.primary,
                      borderWidth: 2,
                      entryRadius: 4,
                      dataEntries: params
                          .map((p) => RadarEntry(value: p.score))
                          .toList(),
                    ),
                  ],
                  radarBackgroundColor: Colors.transparent,
                  borderData: FlBorderData(show: false),
                  radarBorderData:
                      const BorderSide(color: AppTheme.divider, width: 1),
                  gridBorderData:
                      const BorderSide(color: AppTheme.divider, width: 0.5),
                  tickCount: 4,
                  ticksTextStyle: const TextStyle(
                      fontSize: 0, color: Colors.transparent),
                  tickBorderData:
                      const BorderSide(color: AppTheme.divider, width: 0.5),
                  getTitle: (index, angle) {
                    final label = params[index].label;
                    return RadarChartTitle(
                      text: label,
                      angle: angle,
                    );
                  },
                  titleTextStyle: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500),
                  titlePositionPercentageOffset: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
