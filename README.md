Name : Raden Stanislaus Airell Prakosa Sinaga
NPM : 2506657251
Kelas : [E]

### Tugas 7

Aplikasi mobile portofolio pribadi berbasis Flutter, versi mobile dari website portofolio Django saya ([myportofolio](https://github.com/airelprakosa/myportofolio)).

Cara menjalankan (Flutter stable, dikembangkan dengan Flutter 3.47.9):

```
flutter pub get
flutter analyze
flutter test
flutter run -d chrome
```

1. Widget tree adalah susunan bertingkat seluruh widget yang membentuk tampilan aplikasi Flutter, dimulai dari satu widget akar lalu bercabang ke widget anak lewat properti `child` atau `children`. Hubungan induk-anak bekerja dalam tiga arah. Induk membuat anak dan meneruskan data lewat konstruktor, misalnya `MyHomePage` meneruskan `title`, `content`, dan `icon` ke setiap `InfoCard`. Induk juga memberi batasan ukuran ke anak, lalu anak menentukan ukurannya sendiri di dalam batasan itu, misalnya `Expanded` di dalam `Row` membagi lebar secara rata untuk ketiga `InfoCard`. Sebaliknya, anak bisa mengambil data dari leluhurnya lewat `BuildContext`, misalnya `Theme.of(context)` untuk mengambil warna tema dari `MaterialApp`. Susunan aplikasi saya kurang lebih `MyApp` → `MaterialApp` → `MyHomePage` → `Scaffold` → (`AppBar`, `SingleChildScrollView` → `Column` → baris `InfoCard` dan grid `ItemCard`).
2. Widget yang saya gunakan: `MaterialApp` untuk judul, tema, dan halaman awal; `Scaffold` sebagai kerangka halaman sekaligus tempat SnackBar; `AppBar` untuk bar judul; `Text` dan `Icon` untuk teks dan ikon; `SingleChildScrollView` agar halaman bisa digulir dan tidak overflow; `Center` dan `ConstrainedBox` untuk menaruh konten di tengah dan membatasi lebarnya di layar lebar; `Column` dan `Row` untuk menyusun widget vertikal dan horizontal; `Expanded` untuk membagi lebar `Row` secara rata; `IntrinsicHeight` agar ketiga `InfoCard` sama tinggi; `SizedBox` dan `Padding` untuk jarak; `LayoutBuilder` untuk menentukan jumlah kolom tombol (2 atau 4) dari lebar layar; `GridView.count` untuk menampilkan tombol dalam bentuk kisi; `Card` sebagai dasar `InfoCard`; `Material` dan `InkWell` untuk warna latar tombol dan mendeteksi ketukan dengan efek ripple; `Tooltip` untuk penjelasan singkat tiap tombol; dan `SnackBar` lewat `ScaffoldMessenger` untuk pesan setelah tombol ditekan. Selain itu ada widget buatan sendiri, yaitu `MyApp`, `MyHomePage`, `InfoCard`, dan `ItemCard`.
3. `MaterialApp` menyiapkan kebutuhan tingkat aplikasi bergaya Material Design: judul, tema (`ThemeData`), halaman awal (`home`), navigasi (`Navigator`), serta pengaturan bahasa dan arah teks. Widget ini dijadikan root karena banyak widget Material membutuhkan sesuatu yang disediakannya dari atas. Di proyek saya, `Theme.of(context)` membutuhkan tema dari `MaterialApp`, SnackBar membutuhkan `ScaffoldMessenger` yang dibuat `MaterialApp`, dan `Tooltip` membutuhkan `Overlay` dari `Navigator` milik `MaterialApp`. Dengan menaruhnya di akar, semua widget di bawahnya otomatis bisa memakai tema dan layanan tersebut, jadi pengaturannya cukup ditulis sekali.
4. `StatelessWidget` tidak menyimpan data yang berubah; semua field-nya `final`, dan tampilannya hanya di-build ulang kalau induknya memberi konfigurasi baru. `StatefulWidget` punya objek `State` terpisah yang menyimpan data yang bisa berubah, dan bisa mem-build ulang dirinya sendiri dengan `setState()`. `StatelessWidget` dipilih ketika tampilan hanya bergantung pada data tetap atau data dari induknya, sehingga semua widget buatan saya (`MyApp`, `MyHomePage`, `InfoCard`, `ItemCard`) berupa `StatelessWidget`: identitas dan daftar tombolnya tidak berubah selama aplikasi berjalan, dan SnackBar dikelola oleh `ScaffoldMessenger`, bukan oleh widget saya. `StatefulWidget` dipilih ketika tampilan harus berubah karena interaksi atau data yang datang belakangan, misalnya penghitung, isian formulir, tombol star yang berganti status, atau daftar Experience yang nanti diambil dari API Django.
5. `BuildContext` adalah objek yang menunjukkan posisi sebuah widget di dalam widget tree. Flutter memberikannya sebagai parameter `build(BuildContext context)`, dan context inilah yang dipakai untuk mencari data atau layanan dari leluhur, dengan pencarian yang selalu berjalan ke atas. Di proyek saya, `Theme.of(context).colorScheme` dipakai di `MyHomePage` dan `InfoCard` untuk mengambil warna tema, `ScaffoldMessenger.of(context)` dipakai di `ItemCard` untuk menampilkan SnackBar, dan `LayoutBuilder` memberikan `context` serta `constraints` untuk menentukan jumlah kolom tombol. Context harus berada di bawah widget yang dicari; `ScaffoldMessenger.of(context)` di `ItemCard` berhasil karena `ItemCard` berada di bawah `MaterialApp`.
6. Hot reload (tombol `r`) menyuntikkan kode Dart yang berubah ke aplikasi yang sedang berjalan lalu mem-build ulang widget tree, dengan state aplikasi tetap dipertahankan, sehingga perubahan tampilan langsung terlihat. Hot restart (tombol `R`) memuat ulang seluruh kode Dart dan menjalankan aplikasi lagi dari `main()`, sehingga state kembali ke kondisi awal, tetapi tetap lebih cepat daripada menjalankan ulang aplikasi sepenuhnya. Hot reload tidak cukup ketika perubahan ada di kode yang hanya dijalankan sekali (seperti `main()` atau `initState()`), ketika nilai awal variabel global atau field `static` diubah, atau ketika struktur tipe berubah (misalnya `enum` diubah menjadi kelas); untuk kasus ini perlu hot restart. Full restart (menghentikan aplikasi lalu menjalankan `flutter run` lagi) diperlukan ketika perubahan ada di luar kode Dart, misalnya menambah dependensi atau aset di `pubspec.yaml`, atau mengubah konfigurasi native.

### Progres Tugas 7

- Melanjutkan proyek `myportofolio_mobile` dari Tutorial 08 di repositori yang sama, terpisah dari repositori Django.
- `MyHomePage` tetap di `lib/menu.dart` (terpisah dari `main.dart`) sebagai `StatelessWidget`.
- Tiga `InfoCard` menampilkan NPM, nama lengkap, dan kelas saya sendiri.
- Empat `ItemCard` yang relevan dengan portofolio saya: Lihat Experience (biru), Tambah Experience (hijau), Lihat Proyek (ungu), dan Logout (merah).
- SnackBar "Kamu telah menekan tombol [Nama Tombol]!" muncul setiap kali tombol ditekan.
- `flutter analyze` menghasilkan `No issues found!` dan `flutter test` lulus 6 test.

### Fitur tambahan di luar instruksi Tugas 7:

* Tombol keempat (Lihat Proyek) selain tiga tombol minimal, masing-masing dengan warna berbeda yang diatur lewat atribut `color` pada model `ItemHomepage`.
* Tooltip penjelasan pada setiap tombol, muncul saat kursor diarahkan (web) atau saat tombol ditekan lama (mobile).
* SnackBar melayang yang warnanya sama dengan tombol yang ditekan, dilengkapi ikon dan tombol tutup.
* Tata letak responsif: tombol tampil 2 kolom di ponsel dan 4 kolom di layar lebar, lebar konten dibatasi di Chrome, halaman bisa digulir, dan ketiga `InfoCard` dibuat sama tinggi.
* Model dan widget dipisah ke `lib/models/` dan `lib/widgets/` dengan komentar dokumentasi (`///`), serta 6 widget test di `test/widget_test.dart` yang memeriksa data `InfoCard`, warna tombol, dan pesan SnackBar.

### AI Disclosure

Dalam proses pembelajaran dan pengerjaan Tutorial 08 dan Tugas 7 ini, saya memanfaatkan bantuan kecerdasan buatan (AI) yaitu ChatGpt untuk:

* Berdiskusi dan memahami konsep dasar Flutter secara umum, seperti widget tree, `MaterialApp`, perbedaan `StatelessWidget` dan `StatefulWidget`, `BuildContext`, serta hot reload dan hot restart.
* Mempelajari penyusunan layout dan interaksi, seperti `Row`, `Column`, `Expanded`, `GridView`, `InkWell`, `SnackBar`, `Tooltip`, dan perancangan model data untuk warna tombol.
* Memandu instalasi Flutter SDK dan langkah Tutorial 08, serta membantu menulis kode Tugas 7 (model `ItemHomepage`, widget `InfoCard` dan `ItemCard`, `menu.dart`, dan widget test).

Kode dari AI tidak bisa diuji langsung oleh AI karena Flutter tidak dapat dijalankan di lingkungannya, sehingga saya sendiri yang menjalankan `flutter analyze`, `flutter test`, dan `flutter run -d chrome` untuk memastikan semuanya berjalan, lalu mengoreksi AI ketika sarannya keluar dari langkah di PDF tutorial. Data identitas, pilihan bagian portofolio, serta seluruh commit dan push dilakukan oleh saya sendiri.

Strategi prompting yang saya pakai: untuk belajar, saya mengajukan sekitar 20 pertanyaan konsep umum tanpa melampirkan berkas tugas; untuk pengerjaan, saya memberikan PDF tutorial dan tugas sebagai acuan, meminta AI menjelaskan setiap perubahan beserta file yang terdampak, dan mengirim tangkapan layar terminal setiap kali ada error.

log percakapan: (https://chatgpt.com/share/6afaf942-5f6c-83ec-b528-33f11dba2355)
