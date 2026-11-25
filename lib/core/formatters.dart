/// Helper format tanggal & jam dalam Bahasa Indonesia
/// (tanpa package tambahan supaya mudah dijelaskan).
class Formatters {
  static const _days = [
    'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu',
  ];
  static const _months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'Mei', 'Jun',
    'Jul', 'Agu', 'Sep', 'Okt', 'Nov', 'Des',
  ];

  static String _two(int n) => n.toString().padLeft(2, '0');

  /// "14:00"
  static String hour(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';

  /// "Rabu, 25 Nov"
  static String fullDate(DateTime t) =>
      '${_days[t.weekday - 1]}, ${t.day} ${_months[t.month - 1]}';

  /// "Hari ini" untuk index 0, selain itu nama hari, mis. "Kamis".
  static String dayName(DateTime t, int index) =>
      index == 0 ? 'Hari ini' : _days[t.weekday - 1];

  /// "28°"
  static String temp(double v) => '${v.round()}°';
}
