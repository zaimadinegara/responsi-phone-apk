import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../api/api_service.dart';
import '../models/phone.dart';
import '../utils/local_storage_service.dart';
import '../widgets/phone_list_item.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

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
                // debugPrint("Error loading favorite phones: $error"); // Dihapus
                throw error;
              }
              return <Phone>[];
            });
      });
    }
  }

  Widget _buildShimmerList() {
    return ListView.builder(
      padding: const EdgeInsets.all(0),
      itemCount: 3,
      itemBuilder:
          (context, index) => Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Card(
              elevation: 3.0,
              margin: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 90,
                      height: 110,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    const SizedBox(width: 16.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 20,
                            width: double.infinity,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 8),
                          ),
                          Container(
                            height: 16,
                            width: 100,
                            color: Colors.white,
                            margin: const EdgeInsets.only(bottom: 8),
                          ),
                          Container(
                            height: 14,
                            width: 200,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline_rounded,
                                color: Colors.red.shade400,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Gagal memuat favorit.',
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${snapshot.error}',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Coba Lagi'),
                                onPressed: _loadFavoritePhones,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_border_outlined,
                                color: Colors.grey.shade400,
                                size: 80,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada ponsel favorit',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Ketuk ikon hati pada ponsel untuk menambahkannya ke sini.',
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
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
