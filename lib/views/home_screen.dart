import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/weather_code.dart';
import '../viewmodels/view_state.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'search_screen.dart';
import 'widgets/current_weather_section.dart';
import 'widgets/forecast_sections.dart';
import 'widgets/info_grid.dart';
import 'widgets/state_views.dart';

/// VIEW: Home / Weather Screen.
///
/// StatelessWidget karena seluruh state ada di WeatherViewModel.
/// context.watch() membuat screen ini otomatis di-build ulang
/// setiap ViewModel memanggil notifyListeners().
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const SearchScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<WeatherViewModel>();
    final weather = vm.weather;

    // Warna latar mengikuti kondisi cuaca (default: biru cerah).
    final colors = weather == null
        ? WeatherCode.gradient(0)
        : WeatherCode.gradient(weather.current.weatherCode,
            isDay: weather.current.isDay);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: colors,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _TopBar(
                city: vm.location.name,
                subtitle: vm.location.subtitle,
                onSearch: () => _openSearch(context),
              ),
              Expanded(child: _buildBody(context, vm)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, WeatherViewModel vm) {
    final weather = vm.weather;

    // 1) Loading pertama kali (belum ada data sama sekali)
    if (vm.state == ViewState.loading && weather == null) {
      return const LoadingView(
        message: 'Mengambil data cuaca...',
        color: Colors.white,
      );
    }

    // 2) Error
    if (vm.state == ViewState.error && weather == null) {
      return MessageView(
        icon: Icons.cloud_off_rounded,
        title: 'Gagal memuat cuaca',
        message: vm.errorMessage,
        onRetry: vm.loadWeather,
        color: Colors.white,
      );
    }

    // 3) Data kosong
    if (vm.state == ViewState.empty || weather == null) {
      return MessageView(
        icon: Icons.inbox_outlined,
        title: 'Data cuaca kosong',
        message: 'Tidak ada data prakiraan untuk lokasi ini.',
        onRetry: vm.loadWeather,
        color: Colors.white,
      );
    }

    // 4) Sukses -> tampilkan data. Bisa ditarik ke bawah untuk refresh.
    return RefreshIndicator(
      onRefresh: vm.loadWeather,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            child: Center(
              // Batasi lebar di tablet supaya konten tidak terlalu melebar.
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  children: [
                    if (vm.state == ViewState.error)
                      _InlineError(message: vm.errorMessage),
                    CurrentWeatherSection(weather: weather),
                    const SizedBox(height: 24),
                    InfoGrid(weather: weather),
                    const SizedBox(height: 16),
                    if (weather.hourly.isNotEmpty) ...[
                      HourlyForecastSection(hourly: weather.hourly),
                      const SizedBox(height: 16),
                    ],
                    DailyForecastSection(daily: weather.daily),
                    const SizedBox(height: 16),
                    SunSection(today: weather.daily.first),
                    const SizedBox(height: 16),
                    Text(
                      'Sumber data: Open-Meteo.com',
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Baris atas: nama kota terpilih + tombol cari.
class _TopBar extends StatelessWidget {
  final String city;
  final String subtitle;
  final VoidCallback onSearch;

  const _TopBar({
    required this.city,
    required this.subtitle,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 8),
      child: Row(
        children: [
          const Icon(Icons.location_on_rounded, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleLarge?.copyWith(color: Colors.white),
                ),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        textTheme.bodyMedium?.copyWith(color: Colors.white70),
                  ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Cari kota',
            onPressed: onSearch,
            icon: const Icon(Icons.search_rounded, color: Colors.white),
            iconSize: 28,
          ),
        ],
      ),
    );
  }
}

/// Pesan error kecil saat refresh gagal tapi data lama masih ada.
class _InlineError extends StatelessWidget {
  final String? message;
  const _InlineError({this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message ?? 'Gagal memperbarui data.',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
