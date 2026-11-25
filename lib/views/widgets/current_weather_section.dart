import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../core/weather_code.dart';
import '../../models/weather_model.dart';

/// Bagian atas Home: ikon, suhu saat ini, kondisi, suhu terasa, maks/min.
class CurrentWeatherSection extends StatelessWidget {
  final WeatherModel weather;
  const CurrentWeatherSection({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final current = weather.current;
    final today = weather.daily.isNotEmpty ? weather.daily.first : null;

    return Column(
      children: [
        Text(
          'Diperbarui ${Formatters.fullDate(current.time)} • ${Formatters.hour(current.time)}',
          style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
        ),
        const SizedBox(height: 16),
        Icon(
          WeatherCode.icon(current.weatherCode, isDay: current.isDay),
          size: 96,
          color: Colors.white,
        ),
        const SizedBox(height: 8),
        Text(
          Formatters.temp(current.temperature),
          style: textTheme.displayLarge?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 4),
        Text(
          WeatherCode.description(current.weatherCode),
          style: textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
        const SizedBox(height: 6),
        Text(
          'Terasa seperti ${Formatters.temp(current.apparentTemperature)}'
          '${today != null ? '  •  ↑${Formatters.temp(today.tempMax)}  ↓${Formatters.temp(today.tempMin)}' : ''}',
          style: textTheme.bodyLarge?.copyWith(color: Colors.white70),
        ),
      ],
    );
  }
}
