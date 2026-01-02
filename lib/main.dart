import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/district_provider.dart';
import 'providers/mosque_provider.dart';
import 'providers/prayer_time_provider.dart';
import 'providers/favorites_provider.dart';
import 'providers/connectivity_provider.dart';

import 'screens/public/home_screen_new.dart';
import 'widgets/connectivity_banner.dart';
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with auto-generated options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Note: Districts are seeded via Node.js script (seed-bangladesh-data.js)
  // Auto-seeding disabled to avoid permission issues
  // To seed districts, run: node seed-bangladesh-data.js

  runApp(const PrayerTimeApp());
}

class PrayerTimeApp extends StatelessWidget {
  const PrayerTimeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Connectivity Provider (first, so others can depend on it)
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        // Auth Provider
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initializeAuthListener(),
        ),
        // District Provider
        ChangeNotifierProvider(create: (_) => DistrictProvider()),
        // Mosque Provider
        ChangeNotifierProvider(create: (_) => MosqueProvider()),
        // Prayer Time Provider
        ChangeNotifierProvider(create: (_) => PrayerTimeProvider()),
        // Favorites Provider
        ChangeNotifierProvider(
          create: (_) => FavoritesProvider()..initializeFavorites(),
        ),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
            title: 'Jamaat at Masjid',
            theme: AppTheme.lightTheme,
            debugShowCheckedModeBanner: false,
            home: const ConnectivityBanner(child: HomeScreenNew()),
          );
        },
      ),
    );
  }
}
