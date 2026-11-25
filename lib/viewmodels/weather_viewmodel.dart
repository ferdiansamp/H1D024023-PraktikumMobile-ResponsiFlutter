import 'package:flutter/foundation.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';
import '../services/local_storage_service.dart';
import '../services/weather_api_service.dart';
import 'view_state.dart';

/// VIEWMODEL untuk Home / Weather Screen.
///
/// Menyimpan state (lokasi terpilih, data cuaca, status loading/error)
/// dan memanggil Service. Setiap kali state berubah, notifyListeners()
/// membuat widget yang "mendengarkan" (lewat Provider) di-build ulang.
class WeatherViewModel extends ChangeNotifier {
  final WeatherApiService _api;
  final LocalStorageService _storage;

  WeatherViewModel(this._api, this._storage) {
    // Saat aplikasi dibuka: pakai lokasi terakhir, atau Purwokerto jika belum ada.
    _location = _storage.getLastLocation() ?? LocationModel.purwokerto;
    loadWeather();
  }

  // ---------------- State ----------------
  late LocationModel _location;
  WeatherModel? _weather;
  ViewState _state = ViewState.idle;
  String? _errorMessage;

  // Getter supaya View hanya bisa membaca, tidak bisa mengubah langsung.
  LocationModel get location => _location;
  WeatherModel? get weather => _weather;
  ViewState get state => _state;
  String? get errorMessage => _errorMessage;

  // ---------------- Aksi ----------------

  /// Ambil data cuaca untuk lokasi yang sedang dipilih.
  Future<void> loadWeather() async {
    _state = ViewState.loading;
    _errorMessage = null;
    notifyListeners();

    final requested = _location;
    try {
      final result = await _api.fetchWeather(requested);
      // Abaikan hasil jika user sudah pindah lokasi saat request berjalan.
      if (requested != _location) return;
      _weather = result;
      _state = result.daily.isEmpty ? ViewState.empty : ViewState.success;
    } on ApiException catch (e) {
      if (requested != _location) return;
      _errorMessage = e.message;
      _state = ViewState.error;
    }
    notifyListeners();
  }

  /// Dipanggil dari Search Screen ketika user memilih sebuah kota.
  Future<void> selectLocation(LocationModel location) async {
    _location = location;
    _weather = null; // kosongkan data kota sebelumnya
    await _storage.saveLastLocation(location);
    await loadWeather();
  }
}
