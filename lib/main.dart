import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/app_theme.dart';
import 'services/local_storage_service.dart';
import 'services/weather_api_service.dart';
import 'viewmodels/search_viewmodel.dart';
import 'viewmodels/weather_viewmodel.dart';
import 'views/home_screen.dart';

Future<void> main() async {
  // Wajib dipanggil sebelum memakai plugin (Hive) sebelum runApp().
  WidgetsFlutterBinding.ensureInitialized();

  // Siapkan local storage lebih dulu agar data favorit/riwayat
  // sudah tersedia saat aplikasi tampil.
  final storage = LocalStorageService();
  await storage.init();

  final api = WeatherApiService();

  runApp(
    // MultiProvider "menyuntikkan" ViewModel ke pohon widget,
    // sehingga semua screen bisa mengaksesnya.
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WeatherViewModel(api, storage)),
        ChangeNotifierProvider(create: (_) => SearchViewModel(api, storage)),
      ],
      child: const CuacaApp(),
    ),
  );
}

class CuacaApp extends StatelessWidget {
  const CuacaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cuaca',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomeScreen(),
    );
  }
}
