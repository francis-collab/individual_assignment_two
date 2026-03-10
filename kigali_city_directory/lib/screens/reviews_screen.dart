import 'package:flutter/material.dart';

import '../models/listing_model.dart';

class ReviewsScreen extends StatelessWidget {
  final Listing listing;

  const ReviewsScreen({super.key, required this.listing});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews for ${listing.name}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Average Rating: 4.8 ★★★★★',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              '45 reviews',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView(
                children: const [
                  ListTile(
                    leading: CircleAvatar(child: Text('E')),
                    title: Text('Eric'),
                    subtitle: Text('Favo yiliye spot to get rik done\nGreat coffee and friendly staff.'),
                    trailing: Text('★★★★★'),
                  ),
                  Divider(),
                  ListTile(
                    leading: CircleAvatar(child: Text('S')),
                    title: Text('Sarah'),
                    subtitle: Text('Relaxing atmosphere, tasty drinks, and good will.'),
                    trailing: Text('★★★★☆'),
                  ),
                  // Add more static reviews or connect to Firestore subcollection later
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Open add review dialog
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Add review feature coming soon')),
                );
              },
              icon: const Icon(Icons.rate_review),
              label: const Text('Write a Review'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
            ),
          ],
        ),
      ),
    );
  }
}