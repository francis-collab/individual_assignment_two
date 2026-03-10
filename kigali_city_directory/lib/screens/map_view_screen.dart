import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/listing/listing_bloc.dart';
import '../services/listing_service.dart';
import '../models/listing_model.dart';

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  State<MapViewScreen> createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  Set<Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ListingBloc(ListingService())..add(LoadListings()),
      child: BlocBuilder<ListingBloc, ListingState>(
        builder: (context, state) {
          if (state is ListingLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ListingError) {
            return Center(child: Text('Error: ${state.message}'));
          }

          if (state is ListingLoaded) {
            state.listingsStream.listen((listings) {
              if (!mounted) return;
              setState(() {
                _markers = listings
                    .map(
                      (l) => Marker(
                        markerId: MarkerId(l.id),
                        position: l.coordinates,
                        infoWindow: InfoWindow(
                          title: l.name,
                          snippet: l.category,
                        ),
                      ),
                    )
                    .toSet();
              });
            });
          }

          return GoogleMap(
            initialCameraPosition: const CameraPosition(
              target: LatLng(-1.9441, 30.0619), // Kigali center
              zoom: 12,
            ),
            markers: _markers,
            // Optional: add my location button if you want
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          );
        },
      ),
    );
  }
}