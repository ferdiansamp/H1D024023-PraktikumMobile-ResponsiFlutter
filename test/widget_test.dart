import 'package:cuaca_app/models/location_model.dart';
import 'package:cuaca_app/models/weather_model.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit test sederhana: memastikan parsing JSON -> model Dart benar.
/// Jalankan dengan: flutter test
void main() {
  test('LocationModel.fromJson membaca hasil Geocoding API', () {
    final loc = LocationModel.fromJson({
      'id': 1630789,
      'name': 'Purwokerto',
      'latitude': -7.42139,
      'longitude': 109.23444,
      'country': 'Indonesia',
      'admin1': 'Central Java',
    });
    expect(loc.name, 'Purwokerto');
    expect(loc.subtitle, 'Central Java, Indonesia');
  });

  test('WeatherModel.fromJson membaca hasil Forecast API', () {
    // 2026-11-25 07:00 UTC = 14:00 WIB (offset 25200 detik)
    const now = 1795590000;
    final weather = WeatherModel.fromJson({
      'utc_offset_seconds': 25200,
      'timezone': 'Asia/Jakarta',
      'current': {
        'time': now,
        'temperature_2m': 29.4,
        'relative_humidity_2m': 70,
        'apparent_temperature': 33.1,
        'precipitation': 0.2,
        'weather_code': 61,
        'wind_speed_10m': 8.5,
        'is_day': 1,
      },
      'hourly': {
        'time': [now - 3600, now, now + 3600],
        'temperature_2m': [28.0, 29.4, 28.7],
        'weather_code': [3, 61, 63],
        'precipitation_probability': [40, 60, 75],
        'is_day': [1, 1, 1],
      },
      'daily': {
        'time': [1795539600],
        'weather_code': [63],
        'temperature_2m_max': [31.2],
        'temperature_2m_min': [23.5],
        'precipitation_probability_max': [85],
        'sunrise': [1795558800],
        'sunset': [1795603800],
        'uv_index_max': [9.1],
      },
    });

    expect(weather.current.temperature, 29.4);
    expect(weather.current.humidity, 70);
    expect(weather.current.time.hour, 14); // jam lokal WIB
    expect(weather.hourly.length, 2); // jam yang sudah lewat dibuang
    expect(weather.daily.first.tempMax, 31.2);
    expect(weather.todayRainChance, 85);
  });
}
