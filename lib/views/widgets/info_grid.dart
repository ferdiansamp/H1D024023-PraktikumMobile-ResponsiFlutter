import 'package:flutter/material.dart';

import '../../models/weather_model.dart';

/// Grid informasi tambahan: kelembapan, angin, peluang hujan, curah hujan.
/// Jumlah kolom menyesuaikan lebar layar (responsif).
class InfoGrid extends StatelessWidget {
  final WeatherModel weather;
  const InfoGrid({super.key, required this.weather});

  @override
  Widget build(BuildContext context) {
    final c = weather.current;
    final items = [
      _InfoItem(Icons.water_drop_outlined, 'Kelembapan', '${c.humidity}%'),
      _InfoItem(Icons.air_rounded, 'Kecepatan Angin',
          '${c.windSpeed.toStringAsFixed(1)} km/j'),
      _InfoItem(Icons.umbrella_outlined, 'Peluang Hujan',
          '${weather.todayRainChance}%'),
      _InfoItem(Icons.grain_rounded, 'Curah Hujan',
          '${c.precipitation.toStringAsFixed(1)} mm'),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // 2 kolom di HP, 4 kolom di layar lebar (tablet/landscape)
        final columns = constraints.maxWidth > 520 ? 4 : 2;
        const spacing = 12.0;
        final tileWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in items)
              SizedBox(width: tileWidth, child: _InfoTile(item: item)),
          ],
        );
      },
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem(this.icon, this.label, this.value);
}

class _InfoTile extends StatelessWidget {
  final _InfoItem item;
  const _InfoTile({required this.item});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(item.icon, size: 18, color: Colors.white70),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.label,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(color: Colors.white70),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            item.value,
            style: textTheme.titleLarge?.copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
