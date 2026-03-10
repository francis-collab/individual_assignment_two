import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../blocs/auth/auth_bloc.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(uid).snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Text('Error loading profile: ${snap.error}');
                }

                final data = snap.data?.data() as Map<String, dynamic>?;
                final email = data?['email'] as String? ?? user?.email ?? 'No email';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text('Email: $email'),
                      trailing: user?.emailVerified == true
                          ? const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.verified, color: Colors.green, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  'Verified',
                                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                                ),
                              ],
                            )
                          : const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.warning_amber_rounded, color: Colors.red, size: 20),
                                SizedBox(width: 4),
                                Text(
                                  'Not Verified',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ],
                            ),
                    ),
                    if (user?.emailVerified != true)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
                        child: Text(
                          'Check your inbox (including spam) for verification email',
                          style: TextStyle(color: Colors.orange[800], fontSize: 12),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Location-based notifications'),
              value: false, 
              onChanged: (val) {
                // TODO: Save preference (local or Firestore)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Notifications ${val ? 'enabled' : 'disabled'}')),
                );
              },
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                },
                icon: const Icon(Icons.logout),
                label: const Text('Logout'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}