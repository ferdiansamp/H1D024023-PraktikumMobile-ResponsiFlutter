/// Status tampilan yang dipakai ViewModel untuk memberi tahu View
/// apa yang harus digambar.
enum ViewState {
  idle, // belum ada aksi (mis. kolom pencarian masih kosong)
  loading, // sedang menunggu respons API
  success, // data berhasil didapat
  empty, // request berhasil, tapi datanya kosong
  error, // request gagal
}
