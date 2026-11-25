import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';
import 'view_state.dart';

/// VIEWMODEL untuk Search / Location Screen.
///
/// Mengelola: hasil pencarian kota (dari Geocoding API),
/// daftar favorit, dan riwayat pencarian (dari Hive).
class SearchViewModel extends ChangeNotifier {
  final WeatherApiService _api;
  final LocalStorageService _storage;

  SearchViewModel(this._api, this._storage) {
    // Data lokal langsung dimuat saat aplikasi dibuka.
    _favorites = _storage.getFavorites();
    _history = _storage.getHistory();
  }

  // ---------------- State ----------------
  String _query = '';
  List<LocationModel> _results = [];
  ViewState _state = ViewState.idle;
  String? _errorMessage;
  List<LocationModel> _favorites = [];
  List<LocationModel> _history = [];

  Timer? _debounce;
  int _requestId = 0; // untuk mengabaikan respons yang sudah usang

  String get query => _query;
  List<LocationModel> get results => _results;
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;
  List<LocationModel> get favorites => List.unmodifiable(_favorites);
  List<LocationModel> get history => List.unmodifiable(_history);

  bool isFavorite(LocationModel location) => _favorites.contains(location);

  // ---------------- Pencarian ----------------

  /// Dipanggil setiap kali teks berubah. Request baru dikirim setelah
  /// user berhenti mengetik selama 500 ms (debounce) agar tidak boros request.
  void onQueryChanged(String value) {
    _query = value;
    _debounce?.cancel();

    if (value.trim().length < 2) {
      // Open-Meteo butuh minimal 2 huruf; tampilkan favorit & riwayat saja.
      _requestId++;
      _results = [];
      _state = ViewState.idle;
      notifyListeners();
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), search);
  }

  /// Kirim request ke Geocoding API.
  Future<void> search() async {
    _debounce?.cancel();
    final q = _query.trim();
    if (q.length < 2) return;

    final id = ++_requestId;
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _api.searchLocations(q);
      if (id != _requestId) return; // sudah ada pencarian yang lebih baru
      _results = data;
      _state = data.isEmpty ? ViewState.empty : ViewState.success;
    } on ApiException catch (e) {
      if (id != _requestId) return;
      _errorMessage = e.message;
      _state = ViewState.error;
    }
    notifyListeners();
  }

  void clearQuery() => onQueryChanged('');

  // ---------------- Favorit ----------------

  Future<void> toggleFavorite(LocationModel location) async {
    if (isFavorite(location)) {
      _favorites.remove(location);
    } else {
      _favorites.insert(0, location);
    }
    notifyListeners(); // UI langsung berubah
    await _storage.saveFavorites(_favorites); // lalu disimpan ke Hive
  }

  // ---------------- Riwayat ----------------

  Future<void> addToHistory(LocationModel location) async {
    _history = await _storage.addToHistory(location);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    _history = [];
    notifyListeners();
    await _storage.clearHistory();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }
}
