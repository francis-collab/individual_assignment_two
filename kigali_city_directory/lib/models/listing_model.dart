import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';  // For LatLng

class Listing {
  final String id;
  final String name;
  final String category;
  final String address;
  final String contact;
  final String description;
  final LatLng coordinates;
  final String createdBy;
  final Timestamp timestamp;

  Listing({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.contact,
    required this.description,
    required this.coordinates,
    required this.createdBy,
    required this.timestamp,
  });

  factory Listing.fromMap(Map<String, dynamic> data, String id) {
    GeoPoint geo = data['coordinates'];
    return Listing(
      id: id,
      name: data['name'],
      category: data['category'],
      address: data['address'],
      contact: data['contact'],
      description: data['description'],
      coordinates: LatLng(geo.latitude, geo.longitude),
      createdBy: data['createdBy'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'address': address,
      'contact': contact,
      'description': description,
      'coordinates': GeoPoint(coordinates.latitude, coordinates.longitude),
      'createdBy': createdBy,
      'timestamp': timestamp,
    };
  }
}