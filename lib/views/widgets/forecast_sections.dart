import 'package:flutter/material.dart';

import '../../core/formatters.dart';
import '../../core/weather_code.dart';
import '../../models/weather_model.dart';
import 'glass_card.dart';

/// Prakiraan per jam (24 jam ke depan) dalam list horizontal.
class HourlyForecastSection extends StatelessWidget {
  final List<HourlyForecast> hourly;
  const HourlyForecastSection({super.key, required this.hourly});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return GlassCard(
      title: 'PRAKIRAAN PER JAM',
      padding: const EdgeInsets.fromLTRB(16, 16, 0, 16),
      child: SizedBox(
        height: 116,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: hourly.length,
          separatorBuilder: (_, _) => const SizedBox(width: 20),
          itemBuilder: (context, i) {
            final h = hourly[i];
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  i == 0 ? 'Kini' : Formatters.hour(h.time),
                  style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
                Icon(WeatherCode.icon(h.weatherCode, isDay: h.isDay),
                    color: Colors.white),
                Text(
                  '${h.rainChance}%',
                  style: textTheme.bodySmall
                      ?.copyWith(color: const Color(0xFFB3E5FC)),
                ),
                Text(
                  Formatters.temp(h.temperature),
                  style: textTheme.titleMedium?.copyWith(color: Colors.white),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Prakiraan 7 hari: hari, ikon, peluang hujan maks, suhu min & maks.
class DailyForecastSection extends StatelessWidget {
  final List<DailyForecast> daily;
  const DailyForecastSection({super.key, required this.daily});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final white70 = textTheme.bodyLarge?.copyWith(color: Colors.white70);
    final white = textTheme.bodyLarge
        ?.copyWith(color: Colors.white, fontWeight: FontWeight.w600);

    return GlassCard(
      title: 'PRAKIRAAN ${daily.length} HARI',
      child: Column(
        children: [
          for (var i = 0; i < daily.length; i++) ...[
            if (i > 0)
              Divider(color: Colors.white.withValues(alpha: 0.2), height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Text(Formatters.dayName(daily[i].date, i),
                        style: white),
                  ),
                  Icon(WeatherCode.icon(daily[i].weatherCode),
                      color: Colors.white, size: 22),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        const Icon(Icons.umbrella_outlined,
                            size: 14, color: Color(0xFFB3E5FC)),
                        const SizedBox(width: 2),
                        Text(
                          '${daily[i].rainChanceMax}%',
                          style: textTheme.bodyMedium
                              ?.copyWith(color: const Color(0xFFB3E5FC)),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 40,
                    child: Text(Formatters.temp(daily[i].tempMin),
                        textAlign: TextAlign.right, style: white70),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text(Formatters.temp(daily[i].tempMax),
                        textAlign: TextAlign.right, style: white),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Info matahari terbit, terbenam, dan indeks UV hari ini.
class SunSection extends StatelessWidget {
  final DailyForecast today;
  const SunSection({super.key, required this.today});

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      title: 'MATAHARI',
      child: Row(
        children: [
          _sunItem(context, Icons.wb_twilight_rounded, 'Terbit',
              Formatters.hour(today.sunrise)),
          _sunItem(context, Icons.nights_stay_outlined, 'Terbenam',
              Formatters.hour(today.sunset)),
          _sunItem(context, Icons.light_mode_outlined, 'Indeks UV',
              today.uvIndexMax.toStringAsFixed(1)),
        ],
      ),
    );
  }

  Widget _sunItem(
      BuildContext context, IconData icon, String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 6),
          Text(label,
              style: textTheme.bodyMedium?.copyWith(color: Colors.white70)),
          Text(value,
              style: textTheme.titleMedium?.copyWith(color: Colors.white)),
        ],
      ),
    );
  }
}
