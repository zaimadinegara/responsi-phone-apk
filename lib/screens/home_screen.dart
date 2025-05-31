// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../api/api_service.dart';
import '../models/phone.dart';
import '../widgets/phone_list_item.dart';
import 'add_edit_phone_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Phone>> _phonesFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    debugPrint("HomeScreen initState: Calling _fetchData()");
    _fetchData();
  }

  void _fetchData() {
    if (mounted) {
      debugPrint("HomeScreen _fetchData: Setting state for _phonesFuture");
      setState(() {
        _phonesFuture = _apiService.fetchPhones();
      });
    }
  }

  Widget _buildShimmerItem() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Card(
        elevation: 2.0,
        margin: const EdgeInsets.symmetric(vertical: 8.0),
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
                    Container(height: 14, width: 200, color: Colors.white),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SliverList _buildShimmerSliverList() {
    debugPrint("HomeScreen: Building Shimmer SliverList");
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _buildShimmerItem(),
        childCount: 5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPrint("HomeScreen build method called");
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEditPhoneScreen()),
          );
          if (result == true && mounted) {
            _fetchData();
          }
        },
        tooltip: 'Tambah Ponsel Baru',
        backgroundColor: Theme.of(context).colorScheme.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _fetchData(),
        color: Theme.of(context).colorScheme.primary,
        child: CustomScrollView(
          slivers: <Widget>[
            SliverAppBar(
              title: const Text('Katalog Ponsel'),
              floating: true,
              snap: true,
              backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
              foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
              elevation: Theme.of(context).appBarTheme.elevation,
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh_rounded),
                  onPressed: _fetchData,
                  tooltip: 'Refresh',
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              sliver: FutureBuilder<List<Phone>>(
                future: _phonesFuture,
                builder: (context, snapshot) {
                  debugPrint(
                    "HomeScreen FutureBuilder: ConnectionState = ${snapshot.connectionState}",
                  );
                  if (snapshot.hasError) {
                    debugPrint(
                      "HomeScreen FutureBuilder: snapshot.hasError - ${snapshot.error}",
                    );
                  }
                  if (snapshot.hasData) {
                    debugPrint(
                      "HomeScreen FutureBuilder: snapshot.hasData - ${snapshot.data?.length} items",
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _buildShimmerSliverList();
                  } else if (snapshot.hasError) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.cloud_off_rounded,
                                color: Colors.red.shade300,
                                size: 60,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Gagal memuat data ponsel.',
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(color: Colors.grey.shade700),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                "Terjadi kesalahan: ${snapshot.error.toString()}",
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey.shade600),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton.icon(
                                icon: const Icon(Icons.refresh_rounded),
                                label: const Text('Coba Lagi'),
                                onPressed: _fetchData,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        /* ... Empty State UI (sama seperti sebelumnya) ... */
                      ),
                    );
                  } else {
                    final phones = snapshot.data!;
                    return SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final phone = phones[index];
                        return PhoneListItem(
                          phone: phone,
                          onDataChanged: () {
                            _fetchData();
                          },
                        );
                      }, childCount: phones.length),
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
