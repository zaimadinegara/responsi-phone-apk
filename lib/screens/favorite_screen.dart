// lib/screens/favorite_screen.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../api/api_service.dart';
import '../models/phone.dart';
import '../utils/local_storage_service.dart';
import '../widgets/phone_list_item.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key}); // <-- KONSTRUKTOR CONST

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  final ApiService _apiService = ApiService();
  final LocalStorageService _localStorageService = LocalStorageService();
  Future<List<Phone>>? _favoritePhonesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavoritePhones();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted) {
      _loadFavoritePhones();
    }
  }

  Future<void> _loadFavoritePhones() async {
    // ... (Implementasi _loadFavoritePhones sama seperti sebelumnya)
    if (!mounted) return;
    List<String> favoriteIds = await _localStorageService.getFavoritePhoneIds();

    if (!mounted) return;
    if (favoriteIds.isEmpty) {
      if (mounted) {
        setState(() {
          _favoritePhonesFuture = Future.value([]);
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _favoritePhonesFuture = _apiService
            .fetchPhones()
            .then((allPhones) {
              if (!mounted) return <Phone>[];
              final favoritePhones =
                  allPhones
                      .where(
                        (phone) => favoriteIds.contains(phone.id.toString()),
                      )
                      .toList();
              favoritePhones.sort((a, b) {
                int indexA = favoriteIds.indexOf(a.id.toString());
                int indexB = favoriteIds.indexOf(b.id.toString());
                return indexA.compareTo(indexB);
              });
              return favoritePhones;
            })
            .catchError((error) {
              if (mounted) {
                debugPrint("Error loading favorite phones: $error");
                throw error;
              }
              return <Phone>[];
            });
      });
    }
  }

  Widget _buildShimmerList() {
    // ... (Implementasi _buildShimmerList sama seperti sebelumnya)
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: 3,
      itemBuilder:
          (context, index) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Card(/* ... Isi Card Shimmer ... */),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ... (Implementasi build method FavoriteScreen sama seperti versi lengkap terakhir)
    // Termasuk CustomScrollView, SliverAppBar, dan FutureBuilder
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadFavoritePhones,
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              title: const Text('Ponsel Favorit'),
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
              elevation: Theme.of(context).appBarTheme.elevation,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _loadFavoritePhones,
                  tooltip: 'Refresh Favorit',
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
              sliver: FutureBuilder<List<Phone>>(
                future: _favoritePhonesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting &&
                      (snapshot.data == null || snapshot.data!.isEmpty)) {
                    return SliverToBoxAdapter(child: _buildShimmerList());
                  }
                  if (snapshot.hasError) {
                    return SliverFillRemaining(
                      child: Center(child: Text("Error: ${snapshot.error}")),
                    ); // Tampilan error sederhana
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(child: Text("Belum ada ponsel favorit.")),
                    ); // Tampilan kosong sederhana
                  } else {
                    final favoritePhones = snapshot.data!;
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final phone = favoritePhones[index];
                        return PhoneListItem(
                          phone: phone,
                          onDataChanged: () {
                            _loadFavoritePhones();
                          },
                        );
                      }, childCount: favoritePhones.length),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
