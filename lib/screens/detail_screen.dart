import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../api/api_service.dart';
import '../models/phone.dart';
import '../widgets/favorite_button.dart';
import '../utils/local_storage_service.dart';
import 'add_edit_phone_screen.dart';

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
    _fetchDetail();
  }

  void _fetchDetail() {
    if (mounted) {
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
                  color: Theme.of(dialogContext).textTheme.bodySmall?.color,
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
      if (!mounted) return;

      if (success) {
        await LocalStorageService().removeFavoritePhone(phone.id.toString());
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
      if (!mounted) return;
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

  Future<void> _navigateToEditScreen(Phone phone) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddEditPhoneScreen(phone: phone)),
    );
    if (!mounted) return;
    if (result == true) {
      _fetchDetail();
      _dataChangedOnDetail = true;
    }
  }

  Widget _buildShimmerDetail() {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          expandedHeight: MediaQuery.of(context).size.width * 0.75,
          pinned: true,
          backgroundColor: Colors.grey[300],
          flexibleSpace: FlexibleSpaceBar(
            background: Shimmer.fromColors(
              baseColor: Colors.grey[400]!,
              highlightColor: Colors.grey[200]!,
              child: Container(color: Colors.white),
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children:
                      List.generate(
                        5,
                        (index) => Container(
                          width: double.infinity,
                          height: 20,
                          color: Colors.white,
                          margin: const EdgeInsets.only(bottom: 10),
                        ),
                      ).toList(),
                ),
              ),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildDetailRow(
    BuildContext context,
    IconData icon,
    String label,
    String? value,
  ) {
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
            color: Theme.of(
              context,
            ).colorScheme.primary.withAlpha(((0.9 * 255).round())),
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
    final textTheme = Theme.of(context).textTheme;

    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) {
        if (didPop) {}
      },
      child: Scaffold(
        body: FutureBuilder<Phone>(
          future: _phoneDetailFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerDetail();
            } else if (snapshot.hasError) {
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
              return const Center(
                child: Text('Detail ponsel tidak ditemukan.'),
              );
            } else {
              final Phone phone = snapshot.data!;
              return CustomScrollView(
                slivers: <Widget>[
                  SliverAppBar(
                    expandedHeight: MediaQuery.of(context).size.width * 0.8,
                    floating: false,
                    pinned: true,
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    elevation: 1,
                    iconTheme: IconThemeData(
                      color: Theme.of(context).appBarTheme.foregroundColor,
                    ),
                    actions: [
                      IconButton(
                        icon: Icon(
                          Icons.edit_note_outlined,
                          color: Theme.of(context).appBarTheme.foregroundColor,
                        ),
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
                          color: Theme.of(context).appBarTheme.foregroundColor,
                        ),
                        onPressed: () => _confirmDelete(context, phone),
                        tooltip: 'Hapus Ponsel',
                      ),
                    ],
                    flexibleSpace: FlexibleSpaceBar(
                      background: Hero(
                        tag: 'phone-image-${phone.id}',
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: CachedNetworkImage(
                            imageUrl: phone.imgUrl,
                            fit: BoxFit.contain,
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
                        ),
                      ),
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
