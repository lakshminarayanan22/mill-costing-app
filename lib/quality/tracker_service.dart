import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../providers/mill_profile_provider.dart';

// ── Model ───────────────────────────────────────────────────────────────────

class TrackerRecord {
  final String id;
  final DateTime date;
  final String mixNumber;
  final String varietyName;
  final String lotNo;
  final int totalBalesInMix;
  final int balesOfThisLot;
  final double qualityIndex;
  final String indexLabel; // FQI / SCI / PQI

  const TrackerRecord({
    required this.id,
    required this.date,
    required this.mixNumber,
    required this.varietyName,
    required this.lotNo,
    required this.totalBalesInMix,
    required this.balesOfThisLot,
    required this.qualityIndex,
    required this.indexLabel,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': date.toIso8601String(),
        'mixNumber': mixNumber,
        'varietyName': varietyName,
        'lotNo': lotNo,
        'totalBalesInMix': totalBalesInMix,
        'balesOfThisLot': balesOfThisLot,
        'qualityIndex': qualityIndex,
        'indexLabel': indexLabel,
      };

  factory TrackerRecord.fromJson(Map<String, dynamic> j) => TrackerRecord(
        id: j['id'] as String,
        date: DateTime.parse(j['date'] as String),
        mixNumber: j['mixNumber'] as String,
        varietyName: j['varietyName'] as String,
        lotNo: j['lotNo'] as String,
        totalBalesInMix: j['totalBalesInMix'] as int,
        balesOfThisLot: j['balesOfThisLot'] as int,
        qualityIndex: (j['qualityIndex'] as num).toDouble(),
        indexLabel: j['indexLabel'] as String,
      );

  TrackerRecord copyWith({DateTime? date, String? mixNumber, String? varietyName,
      String? lotNo, int? totalBalesInMix, int? balesOfThisLot,
      double? qualityIndex, String? indexLabel}) =>
      TrackerRecord(
        id: id,
        date: date ?? this.date,
        mixNumber: mixNumber ?? this.mixNumber,
        varietyName: varietyName ?? this.varietyName,
        lotNo: lotNo ?? this.lotNo,
        totalBalesInMix: totalBalesInMix ?? this.totalBalesInMix,
        balesOfThisLot: balesOfThisLot ?? this.balesOfThisLot,
        qualityIndex: qualityIndex ?? this.qualityIndex,
        indexLabel: indexLabel ?? this.indexLabel,
      );
}

// Weighted average for a group of records (one day / one period)
double weightedAvg(List<TrackerRecord> records) {
  if (records.isEmpty) return 0;
  final totalBales = records.fold<int>(0, (s, r) => s + r.balesOfThisLot);
  if (totalBales == 0) return 0;
  return records.fold<double>(0, (s, r) => s + r.balesOfThisLot * r.qualityIndex) /
      totalBales;
}

// ── Provider ────────────────────────────────────────────────────────────────

final trackerServiceProvider = Provider<TrackerService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return TrackerService(prefs);
});

final trackerProvider =
    StateNotifierProvider<TrackerNotifier, List<TrackerRecord>>((ref) {
  final svc = ref.watch(trackerServiceProvider);
  return TrackerNotifier(svc, svc.load());
});

class TrackerService {
  static const _key = 'qd_tracker_records';
  final SharedPreferences _prefs;
  TrackerService(this._prefs);

  List<TrackerRecord> load() {
    final raw = _prefs.getString(_key);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => TrackerRecord.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> save(List<TrackerRecord> records) async {
    await _prefs.setString(_key, jsonEncode(records.map((r) => r.toJson()).toList()));
  }
}

class TrackerNotifier extends StateNotifier<List<TrackerRecord>> {
  final TrackerService _svc;
  static const _uuid = Uuid();

  TrackerNotifier(this._svc, super.initial);

  Future<void> add(TrackerRecord record) async {
    final newRecord = TrackerRecord(
      id: _uuid.v4(),
      date: record.date,
      mixNumber: record.mixNumber,
      varietyName: record.varietyName,
      lotNo: record.lotNo,
      totalBalesInMix: record.totalBalesInMix,
      balesOfThisLot: record.balesOfThisLot,
      qualityIndex: record.qualityIndex,
      indexLabel: record.indexLabel,
    );
    state = [...state, newRecord];
    await _svc.save(state);
  }

  Future<void> delete(String id) async {
    state = state.where((r) => r.id != id).toList();
    await _svc.save(state);
  }

  Future<void> clear() async {
    state = [];
    await _svc.save(state);
  }
}
