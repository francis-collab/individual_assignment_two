import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

import 'login_screen.dart';
import 'home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.data == null) {
          return const LoginScreen();
        }

        final user = snapshot.data!;

        if (!user.emailVerified) {
          return const EmailVerificationWaitingScreen();
        }

        return const HomeScreen();
      },
    );
  }
}

class EmailVerificationWaitingScreen extends StatefulWidget {
  const EmailVerificationWaitingScreen({super.key});

  @override
  State<EmailVerificationWaitingScreen> createState() => _EmailVerificationWaitingScreenState();
}

class _EmailVerificationWaitingScreenState extends State<EmailVerificationWaitingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Check verification status every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _checkVerification();
    });
    // Initial check right away
    _checkVerification();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkVerification() async {
    try {
      // Reload user data to get latest emailVerified status
      await FirebaseAuth.instance.currentUser?.reload();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified && mounted) {
        // Verification detected → show success once and navigate to home
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Email verified! Welcome to Kigali Directory'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );

        // Stop the timer
        _timer?.cancel();

        // Automatically go to Home screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }
    } catch (e) {
      // Silent fail — timer will retry
      debugPrint('Verification check error: $e');
    }
  }

  Future<void> _resendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      try {
        await user.sendEmailVerification();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email resent! Check inbox/spam.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 5),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to resend: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 24),
              const Text(
                'Waiting for email verification...',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'We sent a verification link during signup.\n'
                'Please check your inbox (including spam/junk) and click the link.\n\n'
                'The app will automatically continue once verified.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _resendVerificationEmail,
                icon: const Icon(Icons.refresh),
                label: const Text('Resend Verification Email'),
              ),
              const SizedBox(height: 24),
              TextButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                },
                child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}