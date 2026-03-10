import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/listing_model.dart';
import 'reviews_screen.dart';

class DetailScreen extends StatefulWidget {
  final Listing listing;

  const DetailScreen({super.key, required this.listing});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isBookmarked = false; // Local state (can be moved to Bloc/Firestore later)

  Future<void> _launchNavigation() async {
    final url = 'https://www.google.com/maps/dir/?api=1&destination=${widget.listing.coordinates.latitude},${widget.listing.coordinates.longitude}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open Google Maps')),
      );
    }
  }

  void _toggleBookmark() {
    setState(() {
      _isBookmarked = !_isBookmarked;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBookmarked ? 'Added to bookmarks' : 'Removed from bookmarks'),
      ),
    );
    // TODO: Later save to Firestore under user/bookmarks subcollection
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.listing.name),
        actions: [
          IconButton(
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
              color: _isBookmarked ? const Color(0xFFFFD60A) : null,
            ),
            onPressed: _toggleBookmark,
            tooltip: _isBookmarked ? 'Remove bookmark' : 'Add bookmark',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: widget.listing.coordinates,
                  zoom: 15,
                ),
                markers: {
                  Marker(
                    markerId: MarkerId(widget.listing.id),
                    position: widget.listing.coordinates,
                    infoWindow: InfoWindow(title: widget.listing.name),
                  ),
                },
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.listing.name,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text('Category: ${widget.listing.category}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Address: ${widget.listing.address}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Contact: ${widget.listing.contact}', style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  Text(
                    'Description:',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(widget.listing.description, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _launchNavigation,
                        icon: const Icon(Icons.directions),
                        label: const Text('Navigate'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ReviewsScreen(listing: widget.listing),
                            ),
                          );
                        },
                        icon: const Icon(Icons.rate_review),
                        label: const Text('Reviews'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}