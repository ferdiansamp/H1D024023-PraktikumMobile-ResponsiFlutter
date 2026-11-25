/// MODEL: data cuaca hasil Weather Forecast API Open-Meteo.
///
/// Package open_meteo mengirim parameter `timeformat=unixtime` dan
/// `timezone=auto`, sehingga semua waktu di JSON berupa Unix timestamp (detik)
/// dan ada field `utc_offset_seconds` untuk zona waktu lokasi.

/// Ubah Unix timestamp menjadi jam lokal kota tersebut (bukan jam HP).
DateTime _toLocalTime(num unixSeconds, int utcOffsetSeconds) {
  return DateTime.fromMillisecondsSinceEpoch(
    unixSeconds.toInt() * 1000,
    isUtc: true,
  ).add(Duration(seconds: utcOffsetSeconds));
}

/// Ambil angka dari JSON dengan aman (bisa int, double, atau null).
double _toDouble(dynamic value) => (value as num?)?.toDouble() ?? 0;
int _toInt(dynamic value) => (value as num?)?.toInt() ?? 0;

/// Ambil elemen ke-i dari list JSON; kembalikan null jika tidak ada.
dynamic _at(Map<String, dynamic> section, String key, int i) {
  final list = section[key] as List?;
  if (list == null || i >= list.length) return null;
  return list[i];
}

class WeatherModel {
  final String timezone;
  final CurrentWeather current;
  final List<HourlyForecast> hourly; // 24 jam ke depan
  final List<DailyForecast> daily; // 7 hari ke depan

  const WeatherModel({
    required this.timezone,
    required this.current,
    required this.hourly,
    required this.daily,
  });

  /// Parsing seluruh respons JSON Forecast API menjadi model Dart.
  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final offset = _toInt(json['utc_offset_seconds']);
    final current = CurrentWeather.fromJson(
      json['current'] as Map<String, dynamic>,
      offset,
    );

    // ----- Hourly: ambil 24 jam mulai dari jam sekarang -----
    final hourlyJson = (json['hourly'] as Map<String, dynamic>?) ?? {};
    final hourTimes = (hourlyJson['time'] as List?) ?? [];
    final nowUnix = _toInt((json['current'] as Map)['time']);
    final hourly = <HourlyForecast>[];
    for (var i = 0; i < hourTimes.length; i++) {
      final t = _toInt(hourTimes[i]);
      // lewati jam yang sudah berlalu (sisakan jam berjalan)
      if (t + 3600 <= nowUnix) continue;
      hourly.add(HourlyForecast.fromJson(hourlyJson, i, offset));
      if (hourly.length == 24) break;
    }

    // ----- Daily -----
    final dailyJson = (json['daily'] as Map<String, dynamic>?) ?? {};
    final dayTimes = (dailyJson['time'] as List?) ?? [];
    final daily = [
      for (var i = 0; i < dayTimes.length; i++)
        DailyForecast.fromJson(dailyJson, i, offset),
    ];

    return WeatherModel(
      timezone: json['timezone'] as String? ?? '',
      current: current,
      hourly: hourly,
      daily: daily,
    );
  }

  /// Peluang hujan hari ini (daily.precipitation_probability_max index 0).
  int get todayRainChance => daily.isNotEmpty ? daily.first.rainChanceMax : 0;
}

/// Kondisi cuaca terkini (blok "current" pada JSON).
class CurrentWeather {
  final DateTime time;
  final double temperature; // current.temperature_2m (°C)
  final double apparentTemperature; // current.apparent_temperature (°C)
  final int humidity; // current.relative_humidity_2m (%)
  final double precipitation; // current.precipitation (mm)
  final int weatherCode; // current.weather_code (kode WMO)
  final double windSpeed; // current.wind_speed_10m (km/j)
  final bool isDay; // current.is_day (1 = siang, 0 = malam)

  const CurrentWeather({
    required this.time,
    required this.temperature,
    required this.apparentTemperature,
    required this.humidity,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
    required this.isDay,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json, int offset) {
    return CurrentWeather(
      time: _toLocalTime(_toInt(json['time']), offset),
      temperature: _toDouble(json['temperature_2m']),
      apparentTemperature: _toDouble(json['apparent_temperature']),
      humidity: _toInt(json['relative_humidity_2m']),
      precipitation: _toDouble(json['precipitation']),
      weatherCode: _toInt(json['weather_code']),
      windSpeed: _toDouble(json['wind_speed_10m']),
      isDay: _toInt(json['is_day']) == 1,
    );
  }
}

/// Prakiraan per jam (blok "hourly").
class HourlyForecast {
  final DateTime time;
  final double temperature;
  final int weatherCode;
  final int rainChance;
  final bool isDay;

  const HourlyForecast({
    required this.time,
    required this.temperature,
    required this.weatherCode,
    required this.rainChance,
    required this.isDay,
  });

  factory HourlyForecast.fromJson(Map<String, dynamic> json, int i, int offset) {
    return HourlyForecast(
      time: _toLocalTime(_toInt(_at(json, 'time', i)), offset),
      temperature: _toDouble(_at(json, 'temperature_2m', i)),
      weatherCode: _toInt(_at(json, 'weather_code', i)),
      rainChance: _toInt(_at(json, 'precipitation_probability', i)),
      isDay: _toInt(_at(json, 'is_day', i)) == 1,
    );
  }
}

/// Prakiraan harian (blok "daily").
class DailyForecast {
  final DateTime date;
  final int weatherCode; // daily.weather_code
  final double tempMax; // daily.temperature_2m_max
  final double tempMin; // daily.temperature_2m_min
  final int rainChanceMax; // daily.precipitation_probability_max
  final DateTime sunrise;
  final DateTime sunset;
  final double uvIndexMax;

  const DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
    required this.rainChanceMax,
    required this.sunrise,
    required this.sunset,
    required this.uvIndexMax,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json, int i, int offset) {
    return DailyForecast(
      date: _toLocalTime(_toInt(_at(json, 'time', i)), offset),
      weatherCode: _toInt(_at(json, 'weather_code', i)),
      tempMax: _toDouble(_at(json, 'temperature_2m_max', i)),
      tempMin: _toDouble(_at(json, 'temperature_2m_min', i)),
      rainChanceMax: _toInt(_at(json, 'precipitation_probability_max', i)),
      sunrise: _toLocalTime(_toInt(_at(json, 'sunrise', i)), offset),
      sunset: _toLocalTime(_toInt(_at(json, 'sunset', i)), offset),
      uvIndexMax: _toDouble(_at(json, 'uv_index_max', i)),
    );
  }
}
