import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'firebase_options.dart';

// Services
import 'services/auth_service.dart';
import 'services/listing_service.dart';

// Blocs
import 'blocs/auth/auth_bloc.dart';
import 'blocs/listing/listing_bloc.dart';

// Screens
import 'screens/auth_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('Firebase initialized successfully');
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(AuthService()),
        ),
        BlocProvider<ListingBloc>(
          create: (context) => ListingBloc(ListingService()),
        ),
      ],
      child: MaterialApp(
        title: 'Kigali City Directory',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          primaryColor: const Color(0xFF0D1B2A),
          scaffoldBackgroundColor: const Color(0xFF0A1421),
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFFFFD60A),
            brightness: Brightness.dark,
            primary: const Color(0xFFFFD60A),
            secondary: const Color(0xFF778DA9),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1B263B),
            elevation: 0,
            centerTitle: true,
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1B263B),
            selectedItemColor: Color(0xFFFFD60A),
            unselectedItemColor: Colors.grey,
          ),
          cardTheme: const CardThemeData(
            color: Color(0xFF1B263B),
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFD60A),
              foregroundColor: const Color(0xFF0A1421),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          textTheme: const TextTheme(
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white70),
          ),
        ),
        // Removed 'const' because AuthWrapper is stateful and uses BlocBuilder
        home: const AuthWrapper(),
      ),
    );
  }
}