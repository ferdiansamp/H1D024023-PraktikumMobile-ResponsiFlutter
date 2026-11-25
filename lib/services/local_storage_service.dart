import 'package:hive_ce_flutter/hive_flutter.dart';

import '../models/location_model.dart';

/// SERVICE: local storage menggunakan Hive.
///
/// Data disimpan sebagai List<Map> sehingga tidak perlu TypeAdapter /
/// code generation. Ada 3 key di dalam satu box:
///  - favorites      : daftar lokasi favorit
///  - history        : riwayat lokasi yang pernah dibuka (maks. 10)
///  - last_location  : lokasi terakhir yang dilihat di Home
class LocalStorageService {
  static const _boxName = 'cuaca_box';
  static const _favoritesKey = 'favorites';
  static const _historyKey = 'history';
  static const _lastLocationKey = 'last_location';
  static const _maxHistory = 10;

  late Box _box;

  /// Dipanggil sekali di main() sebelum runApp().
  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  // ---------------- Helper konversi ----------------

  List<LocationModel> _readList(String key) {
    final raw = _box.get(key, defaultValue: <dynamic>[]) as List;
    return raw
        .map((e) => LocationModel.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  Future<void> _writeList(String key, List<LocationModel> list) {
    return _box.put(key, list.map((e) => e.toJson()).toList());
  }

  // ---------------- Favorit ----------------

  List<LocationModel> getFavorites() => _readList(_favoritesKey);

  Future<void> saveFavorites(List<LocationModel> favorites) =>
      _writeList(_favoritesKey, favorites);

  // ---------------- Riwayat ----------------

  List<LocationModel> getHistory() => _readList(_historyKey);

  /// Tambahkan lokasi ke paling atas riwayat (tanpa duplikat).
  Future<List<LocationModel>> addToHistory(LocationModel location) async {
    final history = getHistory()
      ..remove(location)
      ..insert(0, location);
    final trimmed = history.take(_maxHistory).toList();
    await _writeList(_historyKey, trimmed);
    return trimmed;
  }

  Future<void> clearHistory() => _box.delete(_historyKey);

  // ---------------- Lokasi terakhir ----------------

  LocationModel? getLastLocation() {
    final raw = _box.get(_lastLocationKey);
    if (raw == null) return null;
    return LocationModel.fromJson(Map<String, dynamic>.from(raw as Map));
  }

  Future<void> saveLastLocation(LocationModel location) =>
      _box.put(_lastLocationKey, location.toJson());
}
