import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../blocs/listing/listing_bloc.dart';
import '../models/listing_model.dart';
import 'detail_screen.dart';
import '../widgets/create_listing_dialog.dart'; 

class MyListingsScreen extends StatefulWidget {
  const MyListingsScreen({super.key});

  @override
  State<MyListingsScreen> createState() => _MyListingsScreenState();
}

class _MyListingsScreenState extends State<MyListingsScreen> {
  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      context.read<ListingBloc>().add(LoadListings(isMyListings: true, uid: uid));
    }
  }

  void _openCreateDialog() {
    showDialog(
      context: context,
      builder: (context) => CreateListingDialog(
        onSave: (listing) {
          context.read<ListingBloc>().add(CreateListingEvent(listing));
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Listing created!')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your listings')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openCreateDialog,
        tooltip: 'Add new listing',
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ListingBloc, ListingState>(
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
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final myListings = snapshot.data!;
                if (myListings.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bookmark_border, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('You have no listings yet', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text('Tap the + button to create your first one!', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<ListingBloc>().add(LoadListings(isMyListings: true, uid: uid));
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemCount: myListings.length,
                    itemBuilder: (context, index) {
                      final listing = myListings[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFFFFD60A),
                            child: Text(
                              listing.category.isNotEmpty ? listing.category[0].toUpperCase() : '?',
                              style: const TextStyle(color: Color(0xFF0A1421), fontWeight: FontWeight.bold),
                            ),
                          ),
                          title: Text(listing.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(listing.category),
                              const SizedBox(height: 4),
                              Text(listing.address, style: const TextStyle(color: Colors.white70)),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                onPressed: () {
                                  // TODO: Open edit dialog (pre-fill with listing data)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Edit: ${listing.name} (coming soon)')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: const Text('Delete Listing'),
                                      content: Text('Are you sure you want to delete "${listing.name}"?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(context),
                                          child: const Text('Cancel'),
                                        ),
                                        TextButton(
                                          style: TextButton.styleFrom(foregroundColor: Colors.red),
                                          onPressed: () {
                                            context.read<ListingBloc>().add(DeleteListingEvent(listing.id));
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Listing deleted'), backgroundColor: Colors.red),
                                            );
                                          },
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => DetailScreen(listing: listing)),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const Center(child: Text('No data available'));
        },
      ),
    );
  }
}