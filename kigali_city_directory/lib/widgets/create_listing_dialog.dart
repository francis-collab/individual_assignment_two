import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ← Added this import

import '../models/listing_model.dart';

class CreateListingDialog extends StatefulWidget {
  final Listing? initialListing; // For edit mode (optional)
  final Function(Listing) onSave;

  const CreateListingDialog({
    super.key,
    this.initialListing,
    required this.onSave,
  });

  @override
  State<CreateListingDialog> createState() => _CreateListingDialogState();
}

class _CreateListingDialogState extends State<CreateListingDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _category;
  late String _address;
  late String _contact;
  late String _description;
  late double _latitude;
  late double _longitude;

  final List<String> _categories = [
    'Café',
    'Restaurant',
    'Pharmacy',
    'Hospital',
    'Police Station',
    'Library',
    'Park',
    'Tourist Attraction',
    'Hotel',
  ];

  @override
  void initState() {
    super.initState();
    if (widget.initialListing != null) {
      _name = widget.initialListing!.name;
      _category = widget.initialListing!.category;
      _address = widget.initialListing!.address;
      _contact = widget.initialListing!.contact;
      _description = widget.initialListing!.description;
      _latitude = widget.initialListing!.coordinates.latitude;
      _longitude = widget.initialListing!.coordinates.longitude;
    } else {
      _name = '';
      _category = _categories.first;
      _address = '';
      _contact = '';
      _description = '';
      _latitude = -1.9441; // Default Kigali
      _longitude = 30.0619;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialListing == null ? 'Add New Listing' : 'Edit Listing'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => _name = v!,
              ),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(labelText: 'Address'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => _address = v!,
              ),
              TextFormField(
                initialValue: _contact,
                decoration: const InputDecoration(labelText: 'Contact Number'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
                onSaved: (v) => _contact = v!,
              ),
              TextFormField(
                initialValue: _description,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 3,
                onSaved: (v) => _description = v ?? '',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _latitude.toString(),
                      decoration: const InputDecoration(labelText: 'Latitude'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                      onSaved: (v) => _latitude = double.parse(v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      initialValue: _longitude.toString(),
                      decoration: const InputDecoration(labelText: 'Longitude'),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v!.isEmpty) return 'Required';
                        if (double.tryParse(v) == null) return 'Invalid number';
                        return null;
                      },
                      onSaved: (v) => _longitude = double.parse(v!),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final newListing = Listing(
                id: widget.initialListing?.id ?? '', // ID will be generated by Firestore
                name: _name,
                category: _category,
                address: _address,
                contact: _contact,
                description: _description,
                coordinates: LatLng(_latitude, _longitude),
                createdBy: FirebaseAuth.instance.currentUser!.uid, 
                timestamp: Timestamp.now(),
              );
              widget.onSave(newListing);
            }
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
} 