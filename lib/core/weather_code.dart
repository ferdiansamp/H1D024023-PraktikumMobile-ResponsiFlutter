import 'package:flutter/material.dart';

/// Kelompok kondisi cuaca, dipakai untuk memilih ikon dan warna gradien.
enum WeatherGroup { clear, partlyCloudy, cloudy, fog, drizzle, rain, snow, thunder }

/// Menerjemahkan kode cuaca WMO (field `weather_code`) dari Open-Meteo.
/// Daftar kode: https://open-meteo.com/en/docs (bagian "WMO Weather interpretation codes")
class WeatherCode {
  static WeatherGroup group(int code) {
    if (code == 0) return WeatherGroup.clear;
    if (code == 1 || code == 2) return WeatherGroup.partlyCloudy;
    if (code == 3) return WeatherGroup.cloudy;
    if (code == 45 || code == 48) return WeatherGroup.fog;
    if (code >= 51 && code <= 57) return WeatherGroup.drizzle;
    if ((code >= 61 && code <= 67) || (code >= 80 && code <= 82)) {
      return WeatherGroup.rain;
    }
    if ((code >= 71 && code <= 77) || code == 85 || code == 86) {
      return WeatherGroup.snow;
    }
    if (code >= 95) return WeatherGroup.thunder;
    return WeatherGroup.cloudy;
  }

  static String description(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
        return 'Cerah Berawan';
      case 2:
        return 'Berawan Sebagian';
      case 3:
        return 'Mendung';
      case 45:
      case 48:
        return 'Berkabut';
      case 51:
      case 53:
      case 55:
        return 'Gerimis';
      case 56:
      case 57:
        return 'Gerimis Beku';
      case 61:
        return 'Hujan Ringan';
      case 63:
        return 'Hujan Sedang';
      case 65:
        return 'Hujan Lebat';
      case 66:
      case 67:
        return 'Hujan Beku';
      case 71:
      case 73:
      case 75:
      case 77:
        return 'Salju';
      case 80:
        return 'Hujan Lokal Ringan';
      case 81:
        return 'Hujan Lokal Sedang';
      case 82:
        return 'Hujan Lokal Lebat';
      case 85:
      case 86:
        return 'Hujan Salju';
      case 95:
        return 'Badai Petir';
      case 96:
      case 99:
        return 'Badai Petir & Hujan Es';
      default:
        return 'Tidak Diketahui';
    }
  }

  static IconData icon(int code, {bool isDay = true}) {
    switch (group(code)) {
      case WeatherGroup.clear:
        return isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round;
      case WeatherGroup.partlyCloudy:
        return isDay ? Icons.wb_cloudy_outlined : Icons.nights_stay_outlined;
      case WeatherGroup.cloudy:
        return Icons.cloud_rounded;
      case WeatherGroup.fog:
        return Icons.foggy;
      case WeatherGroup.drizzle:
        return Icons.grain_rounded;
      case WeatherGroup.rain:
        return Icons.water_drop_rounded;
      case WeatherGroup.snow:
        return Icons.ac_unit_rounded;
      case WeatherGroup.thunder:
        return Icons.thunderstorm_rounded;
    }
  }

  /// Warna latar gradien Home Screen sesuai kondisi cuaca & siang/malam.
  static List<Color> gradient(int code, {bool isDay = true}) {
    if (!isDay) {
      switch (group(code)) {
        case WeatherGroup.clear:
        case WeatherGroup.partlyCloudy:
          return const [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)];
        case WeatherGroup.thunder:
          return const [Color(0xFF141E30), Color(0xFF243B55)];
        default:
          return const [Color(0xFF232526), Color(0xFF414345)];
      }
    }
    switch (group(code)) {
      case WeatherGroup.clear:
        return const [Color(0xFF2F80ED), Color(0xFF56CCF2)];
      case WeatherGroup.partlyCloudy:
        return const [Color(0xFF4A90E2), Color(0xFF9CC3E6)];
      case WeatherGroup.cloudy:
      case WeatherGroup.fog:
        return const [Color(0xFF606C88), Color(0xFF9AA5B8)];
      case WeatherGroup.drizzle:
      case WeatherGroup.rain:
        return const [Color(0xFF3A6073), Color(0xFF16222A)];
      case WeatherGroup.snow:
        return const [Color(0xFF83A4D4), Color(0xFFB6FBFF)];
      case WeatherGroup.thunder:
        return const [Color(0xFF373B44), Color(0xFF4286F4)];
    }
  }
}
