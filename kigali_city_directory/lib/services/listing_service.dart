import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/listing_model.dart';

class ListingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'listings';

  Future<void> createListing(Listing listing) async {
    await _firestore.collection(_collection).add(listing.toMap());
  }

  Stream<List<Listing>> getAllListings() {
    return _firestore
        .collection(_collection)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((doc) => Listing.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Stream<List<Listing>> getMyListings(String uid) {
    return _firestore
        .collection(_collection)
        .where('createdBy', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((doc) => Listing.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    });
  }

  Future<void> updateListing(String id, Listing listing) async {
    await _firestore.collection(_collection).doc(id).update(listing.toMap());
  }

  Future<void> deleteListing(String id) async {
    await _firestore.collection(_collection).doc(id).delete();
  }

  Stream<List<Listing>> searchListings(String query, String? category) {
    Query<Map<String, dynamic>> q = _firestore.collection(_collection);

    if (category != null && category.isNotEmpty) {
      q = q.where('category', isEqualTo: category);
    }

    return q.snapshots().map((snap) {
      List<Listing> listings = snap.docs
          .map((doc) => Listing.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();

      if (query.isNotEmpty) {
        listings = listings.where((l) => l.name.toLowerCase().contains(query.toLowerCase())).toList();
      }

      return listings;
    });
  }
}