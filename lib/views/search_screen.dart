import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location_model.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/view_state.dart';
import '../viewmodels/weather_viewmodel.dart';
import 'widgets/state_views.dart';

/// VIEW: Search / Location Screen.
///
/// StatefulWidget karena butuh TextEditingController untuk kolom pencarian
/// (controller harus dibuat di initState dan dibuang di dispose).
/// Data pencarian, favorit, dan riwayat tetap dikelola SearchViewModel.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Isi kolom dengan query terakhir (jika ada).
    _controller =
        TextEditingController(text: context.read<SearchViewModel>().query);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// User memilih kota -> simpan ke riwayat, ganti lokasi di Home, kembali.
  void _selectLocation(LocationModel location) {
    context.read<SearchViewModel>()
      ..addToHistory(location)
      ..clearQuery();
    context.read<WeatherViewModel>().selectLocation(location);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<SearchViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Cari Kota')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    textInputAction: TextInputAction.search,
                    onChanged: vm.onQueryChanged,
                    onSubmitted: (_) => vm.search(),
                    decoration: InputDecoration(
                      hintText: 'Ketik nama kota, mis. Purwokerto',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: vm.query.isEmpty
                          ? null
                          : IconButton(
                              tooltip: 'Hapus',
                              icon: const Icon(Icons.close_rounded),
                              onPressed: () {
                                _controller.clear();
                                vm.clearQuery();
                              },
                            ),
                    ),
                  ),
                ),
                Expanded(child: _buildContent(vm)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(SearchViewModel vm) {
    switch (vm.state) {
      case ViewState.loading:
        return const LoadingView(message: 'Mencari kota...');
      case ViewState.error:
        return MessageView(
          icon: Icons.wifi_off_rounded,
          title: 'Pencarian gagal',
          message: vm.errorMessage,
          onRetry: vm.search,
        );
      case ViewState.empty:
        return MessageView(
          icon: Icons.location_off_outlined,
          title: 'Kota tidak ditemukan',
          message: 'Tidak ada hasil untuk "${vm.query.trim()}". '
              'Coba periksa ejaan nama kota.',
        );
      case ViewState.success:
        return ListView.builder(
          itemCount: vm.results.length,
          itemBuilder: (_, i) => _LocationTile(
            location: vm.results[i],
            isFavorite: vm.isFavorite(vm.results[i]),
            onTap: () => _selectLocation(vm.results[i]),
            onToggleFavorite: () => vm.toggleFavorite(vm.results[i]),
          ),
        );
      case ViewState.idle:
        return _SavedLocations(vm: vm, onSelect: _selectLocation);
    }
  }
}

/// Tampilan saat kolom pencarian kosong: daftar Favorit & Riwayat dari Hive.
class _SavedLocations extends StatelessWidget {
  final SearchViewModel vm;
  final ValueChanged<LocationModel> onSelect;

  const _SavedLocations({required this.vm, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    if (vm.favorites.isEmpty && vm.history.isEmpty) {
      return const MessageView(
        icon: Icons.travel_explore_rounded,
        title: 'Cari kota untuk melihat cuacanya',
        message: 'Tekan ikon bintang untuk menyimpan kota sebagai favorit.',
      );
    }

    return ListView(
      children: [
        if (vm.favorites.isNotEmpty) ...[
          const _SectionHeader(title: 'Favorit'),
          for (final loc in vm.favorites)
            _LocationTile(
              location: loc,
              isFavorite: true,
              onTap: () => onSelect(loc),
              onToggleFavorite: () => vm.toggleFavorite(loc),
            ),
        ],
        if (vm.history.isNotEmpty) ...[
          _SectionHeader(
            title: 'Riwayat Pencarian',
            action: TextButton(
              onPressed: vm.clearHistory,
              child: const Text('Hapus'),
            ),
          ),
          for (final loc in vm.history)
            _LocationTile(
              location: loc,
              isFavorite: vm.isFavorite(loc),
              leadingIcon: Icons.history_rounded,
              onTap: () => onSelect(loc),
              onToggleFavorite: () => vm.toggleFavorite(loc),
            ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Widget? action;
  const _SectionHeader({required this.title, this.action});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 8, 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.primary),
            ),
          ),
          if (action != null) action!,
        ],
      ),
    );
  }
}

/// Satu baris lokasi: nama kota, provinsi/negara, dan tombol favorit.
class _LocationTile extends StatelessWidget {
  final LocationModel location;
  final bool isFavorite;
  final IconData leadingIcon;
  final VoidCallback onTap;
  final VoidCallback onToggleFavorite;

  const _LocationTile({
    required this.location,
    required this.isFavorite,
    required this.onTap,
    required this.onToggleFavorite,
    this.leadingIcon = Icons.location_city_rounded,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Card(
        child: ListTile(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onTap: onTap,
          leading: CircleAvatar(
            backgroundColor: scheme.primaryContainer,
            child: Icon(leadingIcon, color: scheme.onPrimaryContainer),
          ),
          title: Text(location.name,
              style: Theme.of(context).textTheme.titleMedium),
          subtitle: location.subtitle.isEmpty ? null : Text(location.subtitle),
          trailing: IconButton(
            tooltip: isFavorite ? 'Hapus dari favorit' : 'Simpan ke favorit',
            onPressed: onToggleFavorite,
            icon: Icon(
              isFavorite ? Icons.star_rounded : Icons.star_border_rounded,
              color: isFavorite ? Colors.amber : scheme.outline,
            ),
          ),
        ),
      ),
    );
  }
}
