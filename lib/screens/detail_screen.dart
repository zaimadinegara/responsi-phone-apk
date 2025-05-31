// lib/screens/detail_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../api/api_service.dart';
import '../models/phone.dart';
import '../widgets/favorite_button.dart';
import '../utils/local_storage_service.dart'; // <-- PASTIKAN IMPOR INI ADA DAN TIDAK DIKOMENTARI
import 'add_edit_phone_screen.dart';

// enum ItemType { movie, cloth } // Tidak diperlukan jika screen ini khusus phone

class DetailScreen extends StatefulWidget {
  final String itemId;

  const DetailScreen({super.key, required this.itemId});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  Future<Phone>? _phoneDetailFuture;
  final ApiService _apiService = ApiService();
  bool _dataChangedOnDetail = false;

  @override
  void initState() {
    super.initState();
    debugPrint("DetailScreen initState: itemId = ${widget.itemId}");
    _fetchDetail();
  }

  void _fetchDetail() {
    if (mounted) {
      debugPrint(
        "DetailScreen _fetchDetail: Calling fetchPhoneDetail for ${widget.itemId}",
      );
      setState(() {
        _phoneDetailFuture = _apiService.fetchPhoneDetail(widget.itemId);
      });
    }
  }

  Future<void> _confirmDelete(BuildContext context, Phone phone) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        /* ... (Kode Dialog Konfirmasi sama) ... */
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          title: const Text('Konfirmasi Hapus'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(
                  'Apakah Anda yakin ingin menghapus ponsel "${phone.name}"?',
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text(
                'Batal',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text('Hapus'),
              onPressed: () => Navigator.of(dialogContext).pop(true),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      _performDelete(phone);
    }
  }

  Future<void> _performDelete(Phone phone) async {
    try {
      bool success = await _apiService.deletePhone(phone.id.toString());
      if (success && mounted) {
        await LocalStorageService().removeFavoritePhone(
          phone.id.toString(),
        ); // Pastikan LocalStorageService diimpor jika ini dipakai
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ponsel "${phone.name}" berhasil dihapus.'),
            backgroundColor: Colors.green.shade600,
          ),
        );
        _dataChangedOnDetail = true;
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal menghapus ponsel: ${e.toString().substring(0, (e.toString().length > 100 ? 100 : e.toString().length))}...',
            ),
            backgroundColor: Colors.red.shade600,
          ),
        );
      }
    }
  }

  Future<void> _navigateToEditScreen(Phone phone) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditPhoneScreen(phone: phone)),
    );
    if (result == true && mounted) {
      _fetchDetail();
      _dataChangedOnDetail = true;
    }
  }

  // PERBAIKAN: _buildShimmerDetail() mengembalikan Widget biasa, bukan CustomScrollView
  Widget _buildShimmerDetail() {
    debugPrint("DetailScreen: Building Shimmer Detail");
    return SingleChildScrollView(
      // Atau Column jika konten shimmer tidak panjang
      padding: const EdgeInsets.all(16.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder untuk Gambar Besar
            Container(
              height:
                  MediaQuery.of(context).size.width * 0.7, // Sesuaikan tinggi
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.only(bottom: 20),
            ),
            // Placeholder untuk Judul
            Container(
              width: double.infinity,
              height: 28,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 10),
            ),
            // Placeholder untuk Harga
            Container(
              width: 150,
              height: 24,
              color: Colors.white,
              margin: const EdgeInsets.only(bottom: 16),
            ),
            // Placeholder untuk baris detail
            _buildShimmerDetailRow(),
            _buildShimmerDetailRow(),
            _buildShimmerDetailRow(),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerDetailRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(width: 20, height: 20, color: Colors.white),
          const SizedBox(width: 12),
          Container(width: 80, height: 16, color: Colors.white),
          const SizedBox(width: 8),
          Expanded(child: Container(height: 16, color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String? value,
  ) {
    // ... (Kode _buildDetailRow tetap sama seperti sebelumnya) ...
    if (value == null || value.isEmpty) return const SizedBox.shrink();
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.9),
          ),
          const SizedBox(width: 16),
          Text(
            '$label:',
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: textTheme.bodySmall?.color?.withAlpha(230),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: textTheme.bodyMedium?.copyWith(
                color: textTheme.bodySmall?.color?.withAlpha(210),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      "DetailScreen build method called. _phoneDetailFuture is set: ${_phoneDetailFuture != null}",
    );
    final textTheme = Theme.of(context).textTheme;

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _dataChangedOnDetail);
        return true;
      },
      child: Scaffold(
        // AppBar sekarang dibuat di dalam FutureBuilder atau sebagai AppBar utama Scaffold
        // Jika ingin AppBar tetap terlihat saat loading/error, letakkan di luar FutureBuilder
        // Untuk sementara, kita buat AppBar sederhana di sini, dan AppBar utama akan dibangun
        // saat data sudah ada di dalam CustomScrollView.
        appBar: AppBar(
          title: const Text('Detail Ponsel'), // Judul sementara
          elevation: 0, // Atau 1 jika ingin ada shadow
          backgroundColor:
              Theme.of(
                context,
              ).scaffoldBackgroundColor, // Samakan dengan background
          foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
          iconTheme: Theme.of(context).appBarTheme.iconTheme,
        ),
        body: FutureBuilder<Phone>(
          future: _phoneDetailFuture,
          builder: (context, snapshot) {
            debugPrint(
              "DetailScreen FutureBuilder: ConnectionState = ${snapshot.connectionState}",
            );
            if (snapshot.connectionState == ConnectionState.waiting) {
              debugPrint("DetailScreen FutureBuilder: Waiting for data...");
              return _buildShimmerDetail(); // Menggunakan _buildShimmerDetail yang sudah diperbaiki
            } else if (snapshot.hasError) {
              debugPrint(
                "DetailScreen FutureBuilder: Error - ${snapshot.error}",
              );
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        color: Colors.red[400],
                        size: 60,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Gagal memuat detail ponsel.',
                        style: textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${snapshot.error}',
                        textAlign: TextAlign.center,
                        style: textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.refresh_rounded),
                        label: const Text('Coba Lagi'),
                        onPressed: _fetchDetail,
                      ),
                    ],
                  ),
                ),
              );
            } else if (!snapshot.hasData) {
              debugPrint("DetailScreen FutureBuilder: No data.");
              return const Center(
                child: Text('Detail ponsel tidak ditemukan.'),
              );
            } else {
              final Phone phone = snapshot.data!;
              debugPrint(
                "DetailScreen FutureBuilder: Data received - ${phone.name}",
              );
              return CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: MediaQuery.of(context).size.width * 0.8,
                    floating: false,
                    pinned: true,
                    // backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Dihapus agar gambar bisa jadi background penuh
                    elevation: 1,
                    // iconTheme: IconThemeData(color: Theme.of(context).appBarTheme.foregroundColor), // Dihapus karena diatur oleh AppBar utama atau Scaffold
                    automaticallyImplyLeading: true, // Agar tombol back muncul
                    leading:
                        ModalRoute.of(context)?.canPop == true
                            ? BackButton(color: Colors.white.withOpacity(0.8))
                            : null, // Tombol back putih jika ada gambar
                    actions: [
                      IconButton(
                        icon: Icon(
                          Icons.edit_note_outlined,
                          color: Colors.white.withOpacity(0.8),
                        ), // Buat ikon kontras dengan gambar
                        onPressed: () => _navigateToEditScreen(phone),
                        tooltip: 'Edit Ponsel',
                      ),
                      FavoriteButton(
                        itemId: phone.id.toString(),
                        onFavoriteChanged: (isFavorite) {
                          _dataChangedOnDetail = true;
                        },
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_sweep_outlined,
                          color: Colors.white.withOpacity(0.8),
                        ), // Buat ikon kontras
                        onPressed: () => _confirmDelete(context, phone),
                        tooltip: 'Hapus Ponsel',
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Hero(
                        tag: 'phone-image-${phone.id}',
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            CachedNetworkImage(
                              imageUrl: phone.imgUrl,
                              fit:
                                  BoxFit
                                      .cover, // Cover agar memenuhi FlexibleSpaceBar
                              placeholder:
                                  (context, url) => Shimmer.fromColors(
                                    baseColor: Colors.grey.shade300,
                                    highlightColor: Colors.grey.shade100,
                                    child: Container(color: Colors.white),
                                  ),
                              errorWidget:
                                  (context, url, error) => Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(
                                      Icons.broken_image_outlined,
                                      size: 60,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                            // Gradient agar title AppBar tetap terbaca di atas gambar
                            const DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment(
                                    0.0,
                                    0.9,
                                  ), // Gradient mulai lebih ke bawah
                                  end: Alignment(0.0, 0.0), // Ke atas
                                  colors: <Color>[
                                    Color(
                                      0x99000000,
                                    ), // Hitam transparan di bawah
                                    Color(0x00000000), // Transparan di atas
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Judul bisa ditaruh di sini jika diinginkan, atau di AppBar utama
                      // title: Text(phone.name, style: TextStyle(color: Colors.white, fontSize: 16.0)),
                      // centerTitle: true,
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildListDelegate([
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              phone.name,
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            _buildDetailRow(
                              context,
                              Icons.label_outline_rounded,
                              'Merek',
                              phone.brand,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Spesifikasi:',
                              style: textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                phone.specification,
                                style: textTheme.bodyMedium?.copyWith(
                                  height: 1.5,
                                  color: Colors.grey.shade800,
                                ),
                                textAlign: TextAlign.justify,
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (phone.createdAt != null)
                              _buildDetailRow(
                                context,
                                Icons.calendar_today_outlined,
                                'Dibuat',
                                phone.createdAt.toString().substring(0, 10),
                              ),
                            if (phone.updatedAt != null)
                              _buildDetailRow(
                                context,
                                Icons.edit_calendar_outlined,
                                'Diperbarui',
                                phone.updatedAt.toString().substring(0, 10),
                              ),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ]),
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
