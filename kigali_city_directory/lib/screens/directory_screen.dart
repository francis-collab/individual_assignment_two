import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../blocs/listing/listing_bloc.dart';
import '../models/listing_model.dart';
import 'detail_screen.dart';

class DirectoryScreen extends StatefulWidget {
  const DirectoryScreen({super.key});

  @override
  State<DirectoryScreen> createState() => _DirectoryScreenState();
}

class _DirectoryScreenState extends State<DirectoryScreen> with SingleTickerProviderStateMixin {
  final _searchController = TextEditingController();
  late TabController _tabController;
  Position? _userPosition;

  final List<String> _categories = [
    'All',
    'Café',
    'Pharmacy',
    'Hotel',
    'Restaurant',
    'Park',
    'Tourist Attraction',
    'Hospital',
    'Police Station',
    'Library',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _categories.length, vsync: this);
    _getUserLocation();

    // Load all listings initially
    context.read<ListingBloc>().add(LoadListings());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
      _userPosition = await Geolocator.getCurrentPosition();
      if (mounted) setState(() {});
    }
  }

  double _calculateDistance(LatLng coord) {
    if (_userPosition == null) return 0.0;
    return Geolocator.distanceBetween(
          _userPosition!.latitude,
          _userPosition!.longitude,
          coord.latitude,
          coord.longitude,
        ) /
        1000;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kigali City'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _categories.map((cat) => Tab(text: cat)).toList(),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a service',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[900],
              ),
              onChanged: (val) {
                final currentCategory = _categories[_tabController.index];
                context.read<ListingBloc>().add(
                      SearchListingsEvent(
                        val,
                        currentCategory == 'All' ? null : currentCategory,
                      ),
                    );
              },
            ),
          ),
          Expanded(
            child: BlocBuilder<ListingBloc, ListingState>(
              builder: (context, state) {
                if (state is ListingLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ListingError) {
                  return Center(child: Text('Error: ${state.message}'));
                }
                if (state is ListingLoaded) {
                  return StreamBuilder<List<Listing>>(
                    stream: state.listingsStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }

                      final allListings = snapshot.data ?? [];

                      // Filter based on current tab
                      final selectedCategory = _categories[_tabController.index];
                      final filteredListings = selectedCategory == 'All'
                          ? allListings
                          : allListings.where((l) => l.category == selectedCategory).toList();

                      if (filteredListings.isEmpty) {
                        return const Center(child: Text('No services found in this category'));
                      }

                      return ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: filteredListings.length,
                        itemBuilder: (context, index) {
                          final listing = filteredListings[index];
                          final dist = _calculateDistance(listing.coordinates);
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFFFD60A),
                                child: Text(
                                  listing.category[0].toUpperCase(),
                                  style: const TextStyle(color: Color(0xFF0A1421)),
                                ),
                              ),
                              title: Text(listing.name),
                              subtitle: Text('${listing.category} • ${dist.toStringAsFixed(1)} km'),
                              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => DetailScreen(listing: listing),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      );
                    },
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }
}