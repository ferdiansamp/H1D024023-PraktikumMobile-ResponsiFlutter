/// MODEL: representasi satu lokasi (kota) hasil Geocoding API Open-Meteo.
///
/// Contoh JSON dari endpoint https://geocoding-api.open-meteo.com/v1/search:
/// {
///   "id": 1630789, "name": "Purwokerto",
///   "latitude": -7.42139, "longitude": 109.23444,
///   "country": "Indonesia", "admin1": "Central Java", ...
/// }
class LocationModel {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String? country;
  final String? admin1; // provinsi / negara bagian

  const LocationModel({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.country,
    this.admin1,
  });

  /// Mengubah JSON (Map) dari API menjadi objek Dart.
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      country: json['country'] as String?,
      admin1: json['admin1'] as String?,
    );
  }

  /// Mengubah objek menjadi Map supaya bisa disimpan ke Hive.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'latitude': latitude,
        'longitude': longitude,
        'country': country,
        'admin1': admin1,
      };

  /// Teks keterangan di bawah nama kota, mis. "Central Java, Indonesia".
  String get subtitle =>
      [admin1, country].where((e) => e != null && e.isNotEmpty).join(', ');

  /// Lokasi default saat aplikasi pertama kali dibuka.
  /// Hanya koordinat yang disimpan di sini; data cuacanya tetap diambil dari API.
  static const LocationModel purwokerto = LocationModel(
    id: 1630789,
    name: 'Purwokerto',
    latitude: -7.42139,
    longitude: 109.23444,
    country: 'Indonesia',
    admin1: 'Jawa Tengah',
  );

  // Dua lokasi dianggap sama jika id-nya sama (dipakai untuk cek favorit).
  @override
  bool operator ==(Object other) => other is LocationModel && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
