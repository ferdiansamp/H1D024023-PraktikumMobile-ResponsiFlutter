import 'package:open_meteo/open_meteo.dart';

import '../models/location_model.dart';
import '../models/weather_model.dart';

/// Exception khusus supaya ViewModel bisa menampilkan pesan error yang jelas.
class ApiException implements Exception {
  final String message;
  const ApiException(this.message);

  @override
  String toString() => message;
}

/// SERVICE: lapisan networking.
/// Semua HTTP GET ke Open-Meteo terjadi di sini, lalu JSON-nya diubah
/// menjadi model Dart. ViewModel tidak tahu-menahu soal URL atau JSON.
class WeatherApiService {
  static const _userAgent = 'cuaca_app-responsi-flutter';

  // Weather Forecast API -> GET https://api.open-meteo.com/v1/forecast
  final WeatherApi _weatherApi = const WeatherApi(
    userAgent: _userAgent,
    temperatureUnit: TemperatureUnit.celsius,
    windspeedUnit: WindspeedUnit.kmh,
  );

  // Geocoding API -> GET https://geocoding-api.open-meteo.com/v1/search
  final GeocodingApi _geocodingApi = const GeocodingApi(userAgent: _userAgent);

  /// Ambil cuaca terkini, per jam, dan harian untuk satu lokasi.
  Future<WeatherModel> fetchWeather(LocationModel location) async {
    final Map<String, dynamic> json;
    try {
      // requestJson() melakukan HTTP GET dan mengembalikan JSON (Map).
      // Parameter yang dikirim: latitude, longitude, current, hourly, daily,
      // timezone=auto (otomatis ditambahkan oleh package).
      json = await _weatherApi.requestJson(
        locations: {
          OpenMeteoLocation(
            latitude: location.latitude,
            longitude: location.longitude,
          ),
        },
        current: {
          WeatherCurrent.temperature_2m,
          WeatherCurrent.relative_humidity_2m,
          WeatherCurrent.apparent_temperature,
          WeatherCurrent.precipitation,
          WeatherCurrent.weather_code,
          WeatherCurrent.wind_speed_10m,
          WeatherCurrent.is_day,
        },
        hourly: {
          WeatherHourly.temperature_2m,
          WeatherHourly.weather_code,
          WeatherHourly.precipitation_probability,
          WeatherHourly.is_day,
        },
        daily: {
          WeatherDaily.weather_code,
          WeatherDaily.temperature_2m_max,
          WeatherDaily.temperature_2m_min,
          WeatherDaily.precipitation_probability_max,
          WeatherDaily.sunrise,
          WeatherDaily.sunset,
          WeatherDaily.uv_index_max,
        },
        forecastDays: 7,
      );
    } catch (_) {
      // Biasanya karena tidak ada koneksi internet / timeout.
      throw const ApiException(
          'Gagal terhubung ke server. Periksa koneksi internet kamu.');
    }

    // Jika parameter salah, Open-Meteo membalas {"error": true, "reason": "..."}
    if (json['error'] == true) {
      throw ApiException('Server menolak permintaan: ${json['reason']}');
    }
    if (json['current'] == null) {
      throw const ApiException('Data cuaca tidak tersedia untuk lokasi ini.');
    }

    // JSON -> model Dart
    return WeatherModel.fromJson(json);
  }

  /// Cari kota berdasarkan nama. Mengembalikan list kosong jika tidak ada hasil.
  Future<List<LocationModel>> searchLocations(String query) async {
    final Map<String, dynamic> json;
    try {
      json = await _geocodingApi.requestJson(name: query, count: 15);
    } catch (_) {
      throw const ApiException(
          'Gagal terhubung ke server. Periksa koneksi internet kamu.');
    }

    if (json['error'] == true) {
      throw ApiException('Server menolak permintaan: ${json['reason']}');
    }

    // Jika kota tidak ditemukan, key "results" tidak ada sama sekali.
    final results = json['results'] as List?;
    if (results == null) return [];

    return results
        .map((e) => LocationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
